class Shelf < ApplicationRecord
  has_many :items, inverse_of: :shelf
end
