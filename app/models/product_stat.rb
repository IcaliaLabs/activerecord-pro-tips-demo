class ProductStat < ApplicationRecord
  self.primary_key = 'product_id' # Yes, the product is our primary key... I don't know exactly when
                                  # this will bite my ass...
  belongs_to :product, inverse_of: :stats

  # We may split stats by store... in that case, this model becomes necessary (instead of just
  # storing this data in the `products` table)

  validates :rating, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }

  validates :sell_count, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }
end
