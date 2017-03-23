# frozen_string_literal: true
require 'active_hal/curies'

RSpec.describe ActiveHal::Curies do
  let(:curies) do
    [{
      name: 'acme',
      href: 'http://docs.acme.com/relations/{rel}',
      templated: true
    }]
  end

  subject { described_class.new(curies) }

  describe '#expand' do
    it 'should not expand non-curie relations' do
      expect(subject.expand('widgets')).to eq 'widgets'
    end
    it 'should expand curies with known prefixes' do
      expect(subject.expand('acme:widgets')).to eq 'http://docs.acme.com/relations/widgets'
    end
    it 'should raise a KeyError if the prefix is not defined' do
      expect { subject.expand('foo:widgets') }.to raise_error KeyError
    end
  end
end
