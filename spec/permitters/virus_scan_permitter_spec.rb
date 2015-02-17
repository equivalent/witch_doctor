require 'spec_helper'

describe VirusScanPermitter do
  describe '#attributes' do
    subject { described_class.new.attributes params }

    let(:params) do
       ActionController::Parameters.new({
         virus_scan: {
           scan_result: 'Clean',
           scanned_at: Time.now,
           block_me: 'Not permitted param'
         }
       })
    end

    it 'should filter out unnecessary params' do
      expect(subject).not_to have_key(:block_me)
    end

    it 'should permit necessary params' do
      expect(subject).to have_key(:scan_result)
      expect(subject).to have_key(:scanned_at)
    end
  end
end
