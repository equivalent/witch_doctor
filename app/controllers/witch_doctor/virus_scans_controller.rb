require_dependency "witch_doctor/application_controller"

module WitchDoctor
  class VirusScansController < ApplicationController
    respond_to :json

    # ActionController::UnknownFormat not defined in rails 3. Remove this "if" when all apps are rails 4!!
    rescue_from ActionController::UnknownFormat, with: :incorrect_format if defined?(ActionController::UnknownFormat)

    def index
      authenticate! do
        @virus_scans = VirusScan
          .not_scanned
          .limit(2)
        respond_with @virus_scans
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
                render json: { errors:  @virus_scan.errors }, status: 400
              else
                render json: @virus_scan.reload
              end
            rescue ActionController::ParameterMissing => e
              render json: { errors: { request: [e.to_s] } }, status: 406
            rescue ActiveRecord::RecordNotFound => e
              render json: { errors: { request: ['Record not found or already scanned'] } }, status: 404
            end
          end
          format.html do
            render json: { errors: { request: ['needs to be JSON request'] } }, status: 406
          end
        end
      end
    end

    private

    def authenticate!
      if provided_token == nil
        render json: { errors: { request: ['Not Authenticated'] } }, status: 401
      elsif provided_token.to_s == VirusScan.token
        yield
      else
        render json: { errors: { request: ['Not Authorized'] } }, status: 403
      end
    end

    def provided_token
      (request.headers['HTTP_AUTHORIZATION'] || request.headers['rack.session']['Authorization'])
        .to_s
        .match(/Token\s+(.*)/) { |m| m[1] } \
        || params[:token]
    end

    def virus_scan_params
      VirusScanPermitter.new.attributes(params)
    end

    def incorrect_format
      render json: { errors: { request: ["Incorrect format"] } }, status: 406
    end
  end
end
