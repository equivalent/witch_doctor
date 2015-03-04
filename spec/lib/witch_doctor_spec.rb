require 'spec_helper'

RSpec.describe 'WitchDoctor' do 
  describe '.time_stamper' do
    context 'by default' do
      it 'generate Time.now' do
        expect(WitchDoctor.time_stamper.call)
          .to be_within(10.seconds)
          .of(Time.now)
      end
    end

    context 'passing midnight stamp' do
      before { WitchDoctor.time_stamper = -> { Time.now.midnight } }
      after  { WitchDoctor.time_stamper = nil }

      it 'generate midnight' do
        expect(WitchDoctor.time_stamper.call)
          .to be_within(10.seconds)
          .of(Time.now.midnight)
      end
    end
  end
end
