# frozen_string_literal: true

class Message < ActiveRecord::Base
  update_index("messages_index") { self }
end
