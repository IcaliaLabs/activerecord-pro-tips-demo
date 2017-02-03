#= RandomInventoryGenerator
# Object that is capable of generating random shelves and inventory
class RandomInventoryGenerator
  delegate :generate_shelves, :generate_inbound_order, to: :class

  class << self
    delegate :random_number, to: SecureRandom

    def generate_shelves(quantity = nil)
      # If no quantity was given, specify a random quantity between 5 and 20:
      quantity ||= SecureRandom.random_number(16) + 5
      quantity.times.each { Shelf.create name: FFaker::DizzleIpsum.characters(5) }
    end

    def generate_inbound_order(variety_count: nil, quantity_by_product: nil)
      generate_shelves unless Shelf.any?
      RandomCatalogGenerator.generate_products unless Product.any?
      create_inbound_order_with variety_count, quantity_by_product
    end

    def generate_complete_inbound_order(*args)
      inbound_order = generate_inbound_order *args
      inbound_order.trigger :complete
      inbound_order
    end

    private

    def create_inbound_order_with(variety_count, quantity_by_product)
      inbound_order = InboundOrder.create notes: 'Created by the dummy data filler'
      variety_count ||= random_number(16) + 5
      create_inbound_order_logs inbound_order, variety_count, quantity_by_product
      inbound_order.trigger :receive
      inbound_order
    end

    # Creates a list of InboundOrderLog objects with the given product variations, and given quantity
    # by random product:
    def create_inbound_order_logs(inbound_order, variety_count, quantity_by_product)
      quantity_by_product ||= random_number(901) + 100
      shelf_count, product_count = [Shelf, Product].map(&:count)
      ActiveRecord::Base.transaction do
        variety_count.times.each do
          inbound_order.inbound_logs.create shelf_id: (random_number(shelf_count) + 1),
                                            product_id: (random_number(product_count) + 1),
                                            quantity: quantity_by_product,
                                            properties: { size: random_number(100) }
        end
      end
    end
  end
end
