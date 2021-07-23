# frozen_string_literal: true

require "chewy"

Chewy.settings = {
  transport_options: {
    ssl: {
      verify: false
    }
  }
}
