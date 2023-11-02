# frozen_string_literal: true

require "spec_helper"

describe GraphQL::Connections::Keyset::Desc do
  let_it_be(:msg_a) { Message.create!(body: "A", created_at: Time.local(2020, 10, 2, 15)) }
  let_it_be(:msg_b) { Message.create!(body: "B", created_at: Time.local(2020, 10, 2, 14)) }
  let_it_be(:msg_c) { Message.create!(body: "C", created_at: Time.local(2020, 10, 2, 13)) }
  let_it_be(:msg_d) { Message.create!(body: "D", created_at: Time.local(2020, 10, 2, 12)) }
  let_it_be(:msg_e) { Message.create!(body: "E", created_at: Time.local(2020, 10, 2, 11)) }

  let(:schema) { ApplicationSchema }
  let(:context) { instance_double(GraphQL::Query::Context, schema: schema) }
  let(:relation) { Message.all }
  let(:base_connection) { described_class.new(Message.none, keys: [:body], context: context) }
  let(:connection) { described_class.new(relation, keys: [:body], context: context, **params) }
  let(:nodes) { connection.nodes }
  let(:names) { nodes.map(&:body) }

  describe "default" do
    let(:params) { {} }

    it "returns default_max_page_size nodes" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[E D C]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end

    context "with empty relation" do
      let(:relation) { Message.none }

      it "returns no nodes and has_previous_page and has_next_page are false" do
        expect(nodes.size).to eq 0
        expect(connection.has_previous_page).to be false
        expect(connection.has_next_page).to be false
      end
    end
  end

  describe ":first param" do
    let(:params) { {first: 2} }

    it "returns first two nodes" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[E D]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":last param" do
    let(:params) { {last: 2} }

    it "returns last two nodes" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[B A]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":after param" do
    let(:params) { {after: base_connection.cursor_for(msg_d)} }

    it "returns default_max_page_size nodes after B" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[C B A]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":before param" do
    let(:params) { {before: base_connection.cursor_for(msg_b)} }

    it "returns default_max_page_size nodes before D" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[E D C]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after and :first params" do
    let(:params) { {after: base_connection.cursor_for(msg_d), first: 2} }

    it "returns two nodes after B" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[C B]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":before and :last params" do
    let(:params) { {before: base_connection.cursor_for(msg_b), last: 2} }

    it "returns two nodes before B" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[D C]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after and :last params" do
    let(:params) { {after: base_connection.cursor_for(msg_d), last: 2} }

    it "returns two last nodes after D" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[B A]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":before and :first params" do
    let(:params) { {before: base_connection.cursor_for(msg_b), first: 2} }

    it "returns two first nodes before B" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[E D]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :first, and :last params" do
    let(:params) { {after: base_connection.cursor_for(msg_d), first: 2, last: 2} }

    it "returns three nodes after D" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[C B A]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":before, :last, and :first params" do
    let(:params) { {before: base_connection.cursor_for(msg_b), first: 2, last: 2} }

    it "returns three nodes before B" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[E D C]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :before, and :first params" do
    let(:params) { {after: base_connection.cursor_for(msg_d), before: base_connection.cursor_for(msg_a), first: 1} }

    it "returns first node after D and before A" do
      expect(nodes.size).to eq 1
      expect(names).to eq ["C"]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :before, and :last params" do
    let(:params) { {after: base_connection.cursor_for(msg_d), before: base_connection.cursor_for(msg_a), last: 1} }

    it "returns last node after D and before A" do
      expect(nodes.size).to eq 1
      expect(names).to eq ["B"]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":after, :before, :first, and :last params" do
    let(:params) do
      {after: base_connection.cursor_for(msg_d), before: base_connection.cursor_for(msg_a), first: 1, last: 1}
    end

    it "returns first and last nodes after D and before A" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[C B]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end
end
