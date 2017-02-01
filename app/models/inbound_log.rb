class InboundLog < ApplicationRecord
  belongs_to :inbound_order
  belongs_to :shelf

  # If common order log is going to be extracted to a concern for other order types to use it,
  # this is the stuff you'll want on it:
  belongs_to :product, required: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :without_shelf, -> { where shelf_id: nil }
end
