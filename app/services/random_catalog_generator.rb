#= RandomCatalogGenerator
# Object that is capable of generating random categories and products
class RandomCatalogGenerator
  delegate :generate_categories, :generate_products, to: :class

  def self.generate_categories(quantity = nil)
    # If no quantity was given, specify a random quantity between 5 and 20:
    quantity ||= SecureRandom.random_number(16) + 5
    quantity.times.each { Category.create name: FFaker::Product.product_name }
  end

  def self.generate_products(quantity = nil)
    generate_categories unless Category.any?

    # Fill a list of category ids we can randomly select while creating products:
    category_ids = Category.pluck :id

    # If no quantity was given, specify a random quantity between 5 and 20:
    quantity ||= SecureRandom.random_number(16) + 5
    quantity.times.each do
      random_index = SecureRandom.random_number(category_ids.count - 1)
      Product.create category_id: category_ids[random_index],
                     name: FFaker::Product.product,
                     brand: FFaker::Product.brand
    end
  end
end
