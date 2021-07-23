# frozen_string_literal: true

require "spec_helper"

describe GraphQL::Connections::Chewy, focus: true do
  let_it_be(:msg_a) { create :message, tag: "A", username: "Bart", body: "Bart is super Bart" }
  let_it_be(:msg_b) { create :message, tag: "B", username: "Bart", body: "Hello! I'm Bart!" }
  let_it_be(:msg_c) { create :message, tag: "C", username: "Bart", body: "Do we party today?" }
  let_it_be(:msg_d) { create :message, tag: "D", username: "Jenn", body: "Yes, Bart! Bart sounds crazy!" }
  let_it_be(:msg_e) { create :message, tag: "E", username: "Jenn", body: "Hi Bart!" }
  let_it_be(:msg_f) { create :message, username: "Bart", body: "I'd like to believe", deleted: true }
  let_it_be(:msg_g) { create :message, username: "Jenn", body: "LOL" }

  before_all do
    MessagesIndex.reset!
  end

  let(:schema) { ApplicationSchema }
  let(:context) { instance_double(GraphQL::Query::Context, schema: schema) }
  let(:relation) { MessagesIndex.active_members.search("bart").order("_score") }
  let(:base_connection) { described_class.new(relation, context: context, max_page_size: 100) }
  let(:connection) { described_class.new(relation, context: context, **params) }
  let(:nodes) { connection.nodes }
  let(:names) { nodes.map(&:tag) }

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

    it "ignores `last` param and returns two nodes after B" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[C D]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end

  describe ":before, :last, and :first params" do
    let(:params) { {before: base_connection.cursor_for(msg_d), first: 2, last: 2} }

    it "ignores `last` param and returns two first nodes before D" do
      expect(nodes.size).to eq 2
      expect(names).to eq %w[A B]
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

    it "ignores `last` param and returns first nodes after B and before E" do
      expect(nodes.size).to eq 1
      expect(names).to eq %w[C]
      expect(connection.has_previous_page).to be true
      expect(connection.has_next_page).to be true
    end
  end
end
