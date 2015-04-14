require_dependency "witch_doctor/application_controller"

module WitchDoctor
  class VirusScansController < ApplicationController

    # ActionController::UnknownFormat not defined in rails 3. Remove this "if" when all apps are rails 4!!
    rescue_from ActionController::UnknownFormat, with: :incorrect_format if defined?(ActionController::UnknownFormat)

    def index
      authenticate! do
        @virus_scans = VirusScan
          .not_scanned
          .limit(WitchDoctor.virus_scan_limit)


        respond_to do |format|
          format.json do
            render_json(@virus_scans)
          end
          format.html do
            json_406 = { title: "Not Acceptable",
                         detail: 'needs to be JSON request',
                         status: '406' }
            render json: { errors: [json_406] }, status: 406
          end
        end
      end
    end

    def update
      authenticate! do
        respond_to do |format|
          format.json do
            begin
              @virus_scan = VirusScan.where(scan_result: nil).find params[:id]
              @virus_scan.update_attributes virus_scan_params# as: :scan_update
              if @virus_scan.errors.any?
                json_400 = { title: "Bad Request",
                             detail: @virus_scan.errors.first.join(' '),
                             status: '400' }
                render json: { errors: [json_400] }, status: 400
              else
                render_json(@virus_scan.reload)
              end
            rescue ActionController::ParameterMissing => e
              json_406 = { title: "Not Acceptable",
                           detail: e.to_s,
                           status: '406' }
              render json: { errors: [json_406] }, status: 406
            rescue ActiveRecord::RecordNotFound => e
              json_404 = { title: "Not Found",
                           detail: 'Record not found or already scanned',
                           status:'404' }
              render json: { errors: [json_404] }, status: 404
            end
          end
          format.html do
            err_json = { title: 'Not Acceptable',
                         detail: 'needs to be JSON request',
                         status: '406' }
            render json: { errors: [err_json] }, status: 406
          end
        end
      end
    end

    private

    def authenticate!
      if provided_token == nil
        unauthorized = {title: 'Unauthorized',
                        detail: 'Not Authenticated',
                        status: '401' }
        render json: { errors: [unauthorized] }, status: 401
      elsif provided_token.to_s == WitchDoctor.token
        yield
      else
        forbidden = { title: 'Forbidden',
                      detail: 'Not Authorized',
                      status: '403' }
        render json: { errors: [forbidden] }, status: 403
      end
    end

    def provided_token
      authorization
        .to_s
        .match(/Token\s+(.*)/) { |m| m[1] } \
        || params[:token]
    end

    def authorization
      (rails4 = request.headers['HTTP_AUTHORIZATION']) \
        || (rails3 = request.headers['Authorization']) \
        || (rspec = request.headers['rack.session']['Authorization'])
    end

    def virus_scan_params
      VirusScanPermitter.new.attributes(params)
    end

    def incorrect_format
      json_406 = { title: 'Not Acceptable',
                   detail: "Incorrect format",
                   status: '406' }
      render json: { errors: [json_406] }, status: 406
    end

    def render_json(object)
      if Object.const_defined?('ActiveModel::Serializer')
        render json: object
      else
        render json: { data: object.as_json }
      end
    end
  end
end
