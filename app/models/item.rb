class Item < ApplicationRecord
  belongs_to :inbound_log

  belongs_to :product
  has_one :category, through: :product

  belongs_to :shelf, optional: true

  # I use `define_method` for short, one-liner methods :) Sue me if you don't like it.
  define_method(:available?) { shelf.any? }
end
