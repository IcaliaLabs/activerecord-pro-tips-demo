class Shelf < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :items, inverse_of: :shelf
end
