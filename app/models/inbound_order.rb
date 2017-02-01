class InboundOrder < ApplicationRecord
  has_many :inbound_order_transitions, autosave: false

  has_many :inbound_logs, inverse_of: :inbound_order
  has_many :inbound_shelves, through: :inbound_logs, source: :shelf
end
