require 'spec_helper'

RSpec.describe WitchDoctor::ApplicationHelper, type: :helper do
  describe '#antivirus' do
    subject { antivirus(resource, :attachment) { link_to 'abc', 'http://abc.test'}  }

    let(:resource) {
      build(:document)
        .tap { |document|
          document.virus_scans.new(scan_result: scan_resault, mount_point: 'attachment')
        }
    }

    context 'when not checked' do
      let(:scan_resault) { nil }

      it { expect(subject).to have_content 'File waiting for Antivirus check' }
    end

    context 'when clean' do
      let(:scan_resault) { 'Clean' }

      it { expect(subject).to have_content 'abc' }
      it { expect(subject).to have_selector 'a[href="http://abc.test"]' }
    end

    context 'when infected' do
      let(:scan_resault) { 'VirusInfected' }
      it { expect(subject).to have_content 'File Contains Virus' }
    end

    context 'when error' do
      let(:scan_resault) { 'FileDownloadError' }
      it { expect(subject).to have_content "Antivirus scan couldn't be completed" }
    end
  end
end


