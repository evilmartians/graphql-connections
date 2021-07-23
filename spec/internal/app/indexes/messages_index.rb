# frozen_string_literal: true

class MessagesIndex < Chewy::Index
  settings analysis: {
    filter: {
      autocomplete_filter: {
        type: "edge_ngram",
        min_gram: 2,
        max_gram: 20
      }
    },
    analyzer: {
      autocomplete: {
        type: "custom",
        tokenizer: "standard",
        filter: ["lowercase", "autocomplete_filter"]
      },
      autocomplete_search: {
        type: "custom",
        tokenizer: "standard",
        filter: ["lowercase"]
      }
    }
  }

  index_scope Message.all

  field :username, :body, analyzer: "autocomplete", search_analyzer: "autocomplete_search"
  field :deleted, type: "boolean"
  field :updated_at, type: "date"

  class << self
    def active_members
      filter(term: {deleted: false})
    end

    def search(query)
      query(
        multi_match: {
          query: query,
          type: "most_fields",
          fields: %w[username^2 body],
          fuzziness: 1
        }
      )
    end
  end
end
