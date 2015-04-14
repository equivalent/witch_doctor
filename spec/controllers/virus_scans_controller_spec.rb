require 'spec_helper'
RSpec.describe WitchDoctor::VirusScansController, type: :controller do
  include  ActionController::HttpAuthentication::Token
  routes { WitchDoctor::Engine.routes }

  before do
    # disable creating of virus scan upon document cretaion
    allow_any_instance_of(Document)
      .to receive(:schedule_attachment_virus_scan?)
      .and_return(false)
  end

  before(:all) { WitchDoctor.time_stamper = -> { Time.now.midnight } }
  after(:all)  { WitchDoctor.time_stamper = (reset_stamper_to_default = nil) }

  let(:json_401) do
    %q{{"errors":[{"title":"Unauthorized","detail":"Not Authenticated","status":"401"}]}}
  end

  let(:json_403) do
    %q{{"errors":[{"title":"Forbidden","detail":"Not Authorized","status":"403"}]}}
  end

  describe 'get index' do
    let!(:scheduled_virus_scan1) { create :virus_scan }
    let!(:clean_virus_scan) { create :virus_scan, :clean }
    let(:format) { 'json' }

    context 'without token' do
      it 'responds 401 Not Authenticated' do
        get(:index, format: format)
        expect(response.status).to eq 401
        expect(response.body).to eq json_401
      end
    end

    context 'with invalid token' do
      it 'responds 403 with Not Authorized errors' do
        get(:index, token: 999, format: format)
        expect(response.status).to eq 403
        expect(response.body).to eq %q{{"errors":[{"title":"Forbidden","detail":"Not Authorized","status":"403"}]}}
      end
    end

    context 'with valid token' do
      let!(:scheduled_virus_scan2) { create :virus_scan }

      let(:trigger) { get(:index, token: '1234', format: format) }

      it 'responds 200 with ASC scheduled virus scans' do
        trigger
        expect(response.status).to eq 200
        expect(response.body).to eq("{\"data\":[#{scheduled_virus_scan1.to_json},#{scheduled_virus_scan2.to_json}]}")
      end

      context 'using header token' do
        before do
          get :index,
              {format: format},
              {'Authorization' => "Token 1234"} # when Rails/Rack receives "Authorization" header
                                                     # it aliases this to HTTP_AUTHORIZATION
        end

        it 'responds 200 with ASC scheduled virus scans' do
          expect(response.status).to eq 200
        end
      end

      context 'incorect format request' do
        before { trigger }
        let(:format) { 'html' }
        it{ expect(response.status).to eq 406 }
        it do
          err_json = {
            "errors"=>[
              { "title"=>"Not Acceptable",
                "detail"=>"needs to be JSON request",
                "status"=>"406"}
            ]
          }
          expect(JSON.parse response.body).to match err_json
        end
      end
    end
  end

  describe 'put update' do
    let!(:virus_scan) { create :virus_scan }
    let(:format) { 'json' }

    context 'without token' do
      it 'responds 401 Not Authenticated without changig virus scan' do
        expect do put(:update, id: virus_scan.id, format: format) end
          .not_to change { virus_scan.reload.scan_result }

        expect(response.status).to eq 401
        expect(response.body).to eq json_401
      end
    end

    context 'with invalid token' do
      it 'responds 403 with Not Authorized errors' do
        expect do put(:update, id: virus_scan.id, token: 999.to_s, format: format) end
          .not_to change { virus_scan.reload.scan_result }

        expect(response.status).to eq 403
        expect(response.body).to eq json_403
      end
    end

    context 'with valid token' do
      let(:trigger) {
        put :update,
          id: virus_scan.id,
          token: 1234.to_s,
          format: format,
          virus_scan: virus_scan_params
      }
      let(:virus_scan_params) { { scan_result: 'Clean' } }

      it 'updates scan result and responds 200 virus_change json body' do
        expect(response.status).to eq 200

        expect do trigger end
          .to change { virus_scan.reload.scan_result }
          .from(nil)
          .to('Clean')

        expect(JSON.parse response.body).to match({
          "data" => {
            "id" => virus_scan.id,
            "scan_result" => 'Clean',
            "scanned_at" => Time.now.midnight.utc.iso8601,
            "file_url" => "https://my-s3-bucket.dummy/uploads/documents/blank_pdf.pdf"
          }
        })
      end

      context 'sending missing params' do
        let(:virus_scan_params) { {} }
        it do
          expect do trigger end
            .not_to change { virus_scan.reload.mount_point }

          expect(response.status).to eq 406
          err_json = {
            "errors" => [
              { "title"=>"Not Acceptable",
                "detail"=>"param is missing or the value is empty: virus_scan",
                "status"=>"406" }
            ]
          }
          expect(JSON.parse(response.body)).to match(err_json)
        end
      end

      context 'sending wrong scan result value' do
        let(:virus_scan_params) { { scan_result: 'Wazaaap' } }
        it do
          expect do trigger end
            .not_to change { virus_scan.reload.mount_point }

          expect(response.status).to eq 400

          err_json = {
            "errors" => [
              { 'title' => "Bad Request",
                'detail' => "scan_result is not included in the list",
                'status' => '400' }
            ]
          }
          expect(JSON.parse(response.body)).to match(err_json)
        end
      end

      context 'incorect format request' do
        let(:format) { :html }
        it do
          expect do trigger end
            .not_to change { virus_scan.reload.scan_result }

         expect(response.status).to eq 406

         err_json = {
           "errors"=> [
             { "title"=>"Not Acceptable",
               "detail"=>"needs to be JSON request",
               "status"=>"406" }
           ]
         }
         expect(JSON.parse response.body).to match err_json
        end
      end
    end
  end
end
