class Product < ApplicationRecord
  validates :name, :brand, presence: true
  validates :name, uniqueness: { scope: :brand }
  belongs_to :category

  has_many :items, inverse_of: :product

  scope :available, -> { joins(:items).distinct.merge Item.available }
end
