# frozen_string_literal: true

require "spec_helper"

describe GraphQL::Connections::Stable do
  shared_examples 'Key examples' do |primary_key|
    context 'when desc is false' do
      let(:desc) { false }

      it { is_expected.to be_a(GraphQL::Connections::KeyAsc) }

      it { is_expected.to have_attributes(primary_key: primary_key) }
    end

    context 'when desc is true' do
      let(:desc) { true }

      it 'raises NotImplementedError' do
        expect { subject }.to raise_error(NotImplementedError)
      end
    end
  end

  context 'when primary_key is passed' do
    subject { described_class.new(Message.none, primary_key: 'name', desc: desc) }

    include_examples 'Key examples', 'name'
  end

  context 'when keys are not passed' do
    subject { described_class.new(Message.none, desc: desc) }

    include_examples 'Key examples', 'id'
  end

  context 'when one key is passed' do
    subject { described_class.new(Message.none, keys: %w[name], desc: desc) }

    context 'when desc is false' do
      let(:desc) { false }

      it { is_expected.to be_a(GraphQL::Connections::Keyset::Asc) }

      it('guesses primary key') { is_expected.to have_attributes(field_key: 'name', primary_key: 'id') }
    end

    context 'when desc is true' do
      let(:desc) { true }

      it { is_expected.to be_a(GraphQL::Connections::Keyset::Desc) }

      it('guesses primary key') { is_expected.to have_attributes(field_key: 'name', primary_key: 'id') }
    end
  end

  context 'when two keys are passed' do
    subject { described_class.new(Message.none, keys: %w[name id], desc: desc) }

    context 'when desc is false' do
      let(:desc) { false }

      it { is_expected.to be_a(GraphQL::Connections::Keyset::Asc) }

      it { is_expected.to have_attributes(field_key: 'name', primary_key: 'id') }
    end

    context 'when desc is true' do
      let(:desc) { true }

      it { is_expected.to be_a(GraphQL::Connections::Keyset::Desc) }

      it { is_expected.to have_attributes(field_key: 'name', primary_key: 'id') }
    end
  end

  context 'when more than two keys are passed' do
    subject { described_class.new(Message.none, keys: %w[one two three]) }

    it 'raises ArgumentError' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
