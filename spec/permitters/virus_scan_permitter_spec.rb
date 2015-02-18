require 'spec_helper'

describe VirusScanPermitter do
  describe '#attributes' do
    subject { described_class.new.attributes params }

    let(:params) do
       ActionController::Parameters.new({
         virus_scan: {
           resource_type: 'logo',
           resource_id: '123',
           scan_result: 'Clean',
           mount_point: 'file',
           scanned_at: Time.now
         }
       })
    end

    it 'should filter out unnecessary params' do
      expect(subject.keys).not_to include(
        'resource_type',
        'resource_id',
        'mount_point',
        'scanned_at'
      )
    end

    it 'should permit necessary params' do
      expect(subject.keys).to include(
        'scan_result'
      )
    end
  end
end
