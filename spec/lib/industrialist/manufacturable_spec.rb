require 'spec_helper'

RSpec.describe Industrialist::Manufacturable do
  before(:all) do
    class Automobile
      include Industrialist::Manufacturable
      create_factory :AutomobileFactory
    end
    class Book
      include Industrialist::Manufacturable
      create_factory :BookFactory
    end
  end

  describe '.included' do
    let(:manufacturable_class) do
      Class.new do
        include Industrialist::Manufacturable
        create_factory :AnimalFactory
      end
    end

    before do
      allow(described_class).to receive(:warn).and_call_original
    end

    context 'when the factory is NOT defined on the base class' do
      before { manufacturable_class }

      it 'does NOT warn' do
        expect(described_class).not_to have_received(:warn)
      end
    end

    context 'when the factory is defined on the base class' do
      let(:child_of_manufacturable_class) do
        Class.new(manufacturable_class) do
          include Industrialist::Manufacturable
        end
      end

      before { child_of_manufacturable_class }

      it 'warns' do
        expect(described_class).to have_received(:warn)
      end
    end
  end

  describe '.create_factory' do
    it 'assigns the provided name to the factory instance' do
      expect(AutomobileFactory).to be_an(Industrialist::Factory)
    end

    it 'assigns a different factory instance to each base class' do
      expect(AutomobileFactory.object_id).not_to eq(BookFactory.object_id)
    end
  end

  describe '.corresponds_to' do
    before(:all) do
      class Sedan < Automobile
        corresponds_to :sedan
      end
      class Paperback < Book
        corresponds_to :paperback
      end
      class Coupe < Automobile
        corresponds_to :coupe
      end
    end

    it 'registers the class under the provided key' do
      expect(AutomobileFactory.registry[:sedan]).to equal(Sedan)
      expect(AutomobileFactory.registry[:coupe]).to equal(Coupe)
      expect(BookFactory.registry[:paperback]).to equal(Paperback)
    end

    it 'does NOT register the class in other factories' do
      expect(AutomobileFactory.registry[:paperback]).to be_nil
      expect(BookFactory.registry[:sedan]).to be_nil
      expect(BookFactory.registry[:coupe]).to be_nil
    end
  end
end
