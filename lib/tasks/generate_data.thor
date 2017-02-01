require 'thor/rails'

class GenerateData < Thor
  include Thor::Rails

  desc 'add_categories', 'Generates dummy product categories'
  def add_categories
    catalog_generator.generate_categories ask('How many new categories would you wish to add?').to_i
  end

  desc 'add_products', 'Generates dummy products'
  def add_products
    add_categories unless Category.any?
    catalog_generator.generate_products ask('How many new products would you wish to add?').to_i
  end

  desc 'add_shelves', 'Generates dummy shelves'
  def add_shelves
    inventory_generator.generate_shelves ask('How many new shelves would you wish to add?').to_i
  end

  desc 'add_inventory', 'Generates dummy inventory for testing...'
  def add_inventory
    add_shelves unless Shelf.any?
    add_products unless Product.any?

    params = {
      variety_count: ask('How many different products you wish to add to the order?').to_i,
      quantity_by_product: ask('How many items do you want per product?').to_i,
      complete_order: false # We'll let the user decide when to proceed with the big operation...
    }
    inbound_order = inventory_generator.generate_inbound_order params

    ask('The order is ready to create inventory. Hit ENTER to proceed...')
    inbound_order.trigger :complete

    puts "Finished: Added #{params[:variety_count] * params[:quantity_by_product]} items " \
      "(#{params[:variety_count]} x #{params[:quantity_by_product]}) to inventory!"
  end

  private

  def catalog_generator
    @catalog_generator ||= RandomCatalogGenerator.new
  end

  def inventory_generator
    @inventory_generator ||= RandomInventoryGenerator.new
  end
end
