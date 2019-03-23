require 'spec_helper'

RSpec.describe Industrialist::Factory do
  subject(:factory) { described_class.new }

  let(:key) { :key }
  let(:klass) do
    class TestDummy
      def initialize(_args = nil); end
    end

    TestDummy
  end

  before { factory.register(key, klass) }

  describe '#register' do
    context 'when the key can be symbolized' do
      let(:key) { 'string_key' }

      it 'allows building an instance of the class with the symbolized key' do
        expect(factory.build(key.to_sym)).to be_a(klass)
      end

      it 'allows building an instance of the class with the provided key' do
        expect(factory.build(key)).to be_a(klass)
      end
    end

    context 'when the key is not a symbol or string' do
      let(:key) { { hash: :key } }

      it 'allows building an instance of the class with the provided key' do
        expect(factory.build(key)).to be_a(klass)
      end
    end
  end

  describe '#build' do
    subject(:build) { factory.build(key, params) }

    let(:params) { 'params' }

    before do
      allow(klass).to receive(:new).and_call_original
    end

    it 'builds an instance of the requested class' do
      build

      expect(klass).to have_received(:new).with(params)
    end

    it 'returns an instance of the right class' do
      expect(build).to be_a(klass)
    end
  end
end
