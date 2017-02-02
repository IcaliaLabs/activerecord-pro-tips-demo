class Product < ApplicationRecord
  validates :name, :brand, presence: true
  validates :name, uniqueness: { scope: :brand }
  belongs_to :category
end
