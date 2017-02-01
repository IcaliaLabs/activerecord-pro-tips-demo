#= RandomInventoryGenerator
# Object that is capable of generating random shelves and inventory
class RandomInventoryGenerator
  def generate_shelves(quantity = nil)
    # If no quantity was given, specify a random quantity between 5 and 20:
    quantity ||= SecureRandom.random_number(16) + 5
    quantity.times.each { Shelf.create name: FFaker::DizzleIpsum.characters(5) }
  end

  def generate_inbound_order(variety_count: nil, quantity_by_product: nil, complete_order: true)
    generate_shelves unless Shelf.any?
    RandomCatalogGenerator.new.generate_products unless Product.any?

    # Fill a list of product ids we can randomly select while creating inbound logs:
    shelf_ids = Shelf.pluck :id
    product_ids = Product.pluck :id

    # If no product_quantity was given, specify a random quantity between 5 and 20:
    variety_count ||= SecureRandom.random_number(16) + 5

    # If no quantity_by_product was given, specify a random quantity between 100 and 1000:
    quantity_by_product ||= SecureRandom.random_number(901) + 100

    inbound_order = InboundOrder.create notes: 'Created by the dummy data filler'

    ActiveRecord::Base.transaction do
      variety_count.times.each do
        random_shelf_id = shelf_ids[SecureRandom.random_number(shelf_ids.count - 1)]
        random_product_id = product_ids[SecureRandom.random_number(product_ids.count - 1)]

        inbound_order.inbound_logs.create shelf_id: random_shelf_id,
                                          product_id: random_product_id,
                                          quantity: quantity_by_product,
                                          properties: { size: SecureRandom.random_number(100) }
      end
    end

    # Process the Inbound Order:
    inbound_order.trigger :receive

    inbound_order.trigger :complete if complete_order

    # Return the inbound order:
    inbound_order
  end
end
