require 'rspec/matchers'
require 'ostruct'
require_relative '../../lib/witch_doctor/antivirus'
RSpec.describe WitchDoctor::Antivirus do
  subject { described_class.new(resource, :avatar) }
  let(:resource) { double virus_scans: [virus_scan] }

  context "when unchecked resource" do
    let(:virus_scan) { double scan_result: nil, scanned_at: nil, mount_point: 'avatar' }

    it { expect(subject.checked?).to be false }
    it { expect(subject.infected?).to be false }
    it { expect(subject.clean?).to be false }
    it { expect(subject.error?).to be false }

    context 'along different mont point virus scan' do
      let(:virus_scan2) { double scan_result: 'Clean', scanned_at: Time.now - 3600, mount_point: 'different'}
      let(:resource) { double virus_scans: [virus_scan2, virus_scan, virus_scan2] }

      it { expect(subject.checked?).to be false }
    end
  end

  context "when checked clean resource" do
    let(:virus_scan) { double scan_result: 'Clean', scanned_at: Time.now - 3600, mount_point: 'avatar'}

    it { expect(subject.checked?).to be true }
    it { expect(subject.infected?).to be false }
    it { expect(subject.clean?).to be true }
    it { expect(subject.error?).to be false }
  end

  context "when checked with dowload error" do
    let(:virus_scan) { double scan_result: 'FileDownloadError', scanned_at: Time.now - 3600, mount_point: 'avatar'}

    it { expect(subject.checked?).to be true }
    it { expect(subject.infected?).to be false }
    it { expect(subject.clean?).to be false }
    it { expect(subject.error?).to be true }
  end

  context "when checked with virus resource" do
    let(:virus_scan) { double scan_result: 'VirusInfected', scanned_at: Time.now - 3600, mount_point: 'avatar' }

    it { expect(subject.checked?).to be true }
    it { expect(subject.infected?).to be true }
    it { expect(subject.clean?).to be false }
    it { expect(subject.error?).to be false }

    context 'along different mont point virus scan' do
      let(:virus_scan2) { double scan_result: 'Clean', scanned_at: Time.now - 3600, mount_point: 'different'}
      let(:resource) { double virus_scans: [virus_scan2, virus_scan, virus_scan2] }

      it { expect(subject.infected?).to be true }
      it { expect(subject.clean?).to be false }
    end
  end
end
