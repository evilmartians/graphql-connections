# frozen_string_literal: true

require "spec_helper"

describe GraphQL::Connections::Key::Asc do
  let_it_be(:msg_a) { Message.create!(body: "A", created_at: Time.local(2020, 10, 2, 15)) }
  let_it_be(:msg_b) { Message.create!(body: "B", created_at: Time.local(2020, 10, 2, 14)) }
  let_it_be(:msg_c) { Message.create!(body: "C", created_at: Time.local(2020, 10, 2, 13)) }
  let_it_be(:msg_d) { Message.create!(body: "D", created_at: Time.local(2020, 10, 2, 12)) }
  let_it_be(:msg_e) { Message.create!(body: "E", created_at: Time.local(2020, 10, 2, 11)) }

  let(:schema) { ApplicationSchema }
  let(:query_context) { instance_double(GraphQL::Query::Context, schema: schema) }
  let(:relation) { Message.all }
  let(:base_connection) { described_class.new(Message.none, context: query_context) }
  let(:connection) { described_class.new(relation, context: query_context, **params) }
  let(:nodes) { connection.nodes }
  let(:names) { nodes.map(&:body) }

  describe "default" do
    let(:params) { {} }

    it "returns default_max_page_size nodes" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[A B C]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":first param" do
    let(:params) { {first: 2} }

    it "returns first two nodes" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[A B]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":last param" do
    let(:params) { {last: 2} }

    it "returns last two nodes" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[D E]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":after param" do
    let(:params) { {after: base_connection.cursor_for(msg_b)} }

    it "returns default_max_page_size nodes after B" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[C D E]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":before param" do
    let(:params) { {before: base_connection.cursor_for(msg_d)} }

    it "returns default_max_page_size nodes before D" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[A B C]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after and :first params" do
    let(:params) { {after: base_connection.cursor_for(msg_b), first: 2} }

    it "returns two nodes after B" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[C D]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":before and :last params" do
    let(:params) { {before: base_connection.cursor_for(msg_d), last: 2} }

    it "returns two nodes before D" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[B C]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after and :last params" do
    let(:params) { {after: base_connection.cursor_for(msg_b), last: 2} }

    it "returns two last nodes after B" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[D E]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":before and :first params" do
    let(:params) { {before: base_connection.cursor_for(msg_d), first: 2} }

    it "returns two first nodes before D" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[A B]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :first, and :last params" do
    let(:params) { {after: base_connection.cursor_for(msg_b), first: 2, last: 2} }

    it "returns three nodes after B" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[C D E]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be false
    end
  end

  describe ":before, :last, and :first params" do
    let(:params) { {before: base_connection.cursor_for(msg_d), first: 2, last: 2} }

    it "returns three nodes before D" do
      expect(nodes.size).to eq 3
      expect(names).to eq %w[A B C]
      expect(connection.has_previous_page).to be false
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :before, and :first params" do
    let(:params) { {after: base_connection.cursor_for(msg_b), before: base_connection.cursor_for(msg_e), first: 1} }

    it "returns first node after B and before E" do
      expect(nodes.size).to eq 1
      expect(names).to eq ["C"]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :before, and :last params" do
    let(:params) { {after: base_connection.cursor_for(msg_b), before: base_connection.cursor_for(msg_e), last: 1} }

    it "returns last node after B and before E" do
      expect(nodes.size).to eq 1
      expect(names).to eq ["D"]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":after, :before, :first, and :last params" do
    let(:params) do
      {after: base_connection.cursor_for(msg_b), before: base_connection.cursor_for(msg_e), first: 1, last: 1}
    end

    it "returns first and last nodes after B and before E" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[C D]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  context "when primary is Time" do
    let(:base_connection) { described_class.new(Message.none, primary_key: :created_at, context: query_context) }
    let(:connection) { described_class.new(relation, primary_key: :created_at, context: query_context, **params) }

    describe ":after, :before, :first, and :last params" do
      let(:params) do
        {after: base_connection.cursor_for(msg_d), before: base_connection.cursor_for(msg_a), first: 1, last: 1}
      end

      it "returns first and last nodes after B and before E" do
        expect(nodes.size).to eq 2
        expect(names).to eq %w[C B]
        expect(connection.has_previous_page).to be true
        expect(connection.has_next_page).to be true
      end
    end

    context "and cursor is not opaque" do
      let(:base_connection) do
        described_class.new(Message.none, primary_key: :created_at, opaque_cursor: false, context: query_context)
      end
      let(:connection) do
        described_class.new(relation, primary_key: :created_at, opaque_cursor: false, context: query_context, **params)
      end

      describe ":after, :before, :first, and :last params" do
        let(:params) do
          {after: "2020-10-02 12:00:00", before: "2020-10-02 15:00:00", first: 1, last: 1}
        end

        it "returns first and last nodes after B and before E" do
          expect(nodes.size).to eq 2
          expect(names).to eq %w[C B]
          expect(connection.has_previous_page).to be true
          expect(connection.has_next_page).to be true
        end
      end
    end
  end
end
