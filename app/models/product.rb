class Product < ApplicationRecord
  validates :name, :brand, presence: true
  validates :name, uniqueness: { scope: :brand }
  belongs_to :category

  has_many :items, inverse_of: :product
  has_one :stats, class_name: :ProductStat

  scope :available, -> { joins(:items).distinct.merge Item.available }
end
