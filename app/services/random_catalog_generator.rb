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
    category_count = Category.count

    # If no quantity was given, specify a random quantity between 5 and 20:
    quantity ||= SecureRandom.random_number(16) + 5
    quantity.times.each do
      Product.create! category_id: (SecureRandom.random_number(category_count) + 1),
                      name: FFaker::Product.product,
                      brand: FFaker::Product.brand
    end
  end
end
