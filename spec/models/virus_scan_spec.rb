require 'spec_helper'

describe VirusScan do
  describe '#scanned_at' do
    let!(:virus_scan) { create :virus_scan }

    context 'after updating record with scan results' do
      before { virus_scan.update_attributes({scan_result: 'Clean'}) }

      it 'should be generate' do
        expect(virus_scan.scanned_at).not_to be nil
        expect(virus_scan.scanned_at).to be_within(20.seconds).of(Time.now)
      end
    end

    context 'after updating record not related to scan result' do
      before { virus_scan.update_attributes({scan_result: nil} ) }

      it 'should be generate' do
        expect(virus_scan.scanned_at).to be nil
      end
    end
  end

  describe '.not_scanned' do
    let!(:clean) { create :virus_scan, scan_result: 'Clean' }
    let!(:not_scanned) { create :virus_scan, scan_result: nil }

    it do
      expect(VirusScan.not_scanned).to include not_scanned
      expect(VirusScan.not_scanned).not_to include clean
    end
  end

  describe "as_json" do
    let(:document) { create :document, attachment: 'blank_pdf.pdf' }
    let(:virus_scan) {
      build_stubbed :virus_scan,
        scan_result: nil,
        mount_point: 'attachment',
        resource: document
    }

    it do
      expect(virus_scan.as_json['id']).to eq virus_scan.id
      expect(virus_scan.as_json['scan_result']).to be nil
      expect(virus_scan.as_json['file_url'])
        .to match("https://my-s3-bucket.dummy/uploads/documents/blank_pdf.pdf")
      expect(virus_scan.as_json['scanned_at']).to be nil
    end
  end
end
