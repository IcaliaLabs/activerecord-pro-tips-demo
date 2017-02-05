#= RandomCatalogGenerator
# Object that is capable of generating random categories and products
# RandomCatalogGenerator.generate_products 20000
class RandomCatalogGenerator
  delegate :generate_categories, :generate_products, to: :class
  include Arel::Nodes
  extend Arel::Crud, Arel::FactoryMethods

  class << self
    delegate :connection, to: ActiveRecord::Base
    delegate :execute, to: :connection
    delegate :random_number, to: SecureRandom
  end

  def self.generate_categories(quantity = nil)
    # If no quantity was given, specify a random quantity between 5 and 20:
    quantity ||= random_number(16) + 5
    quantity.times.each { Category.create name: FFaker::Product.product_name }
  end

  def self.generate_products(quantity = nil)
    generate_categories unless Category.any?

    # If no quantity was given, specify a random quantity between 5 and 20:
    quantity ||= random_number(16) + 5
    # Turn down the rails logger - this query may get too damn long!

    mass_create = lambda do
      insert_sql = generate_products_insert(quantity).to_sql
      results = execute "#{insert_sql} RETURNING id", "Product Create"
      results.to_a.map { |result| result['id'] }
    end

    if quantity < 5
      mass_create.call
    else
      Rails.logger.silence { mass_create.call }
    end
  end

  def self.generate_products_insert(quantity)
    manager = create_insert.into Product.arel_table
    manager.columns.concat Product.columns.select { |column| column.name != 'id' }
    manager.select product_list_seed_with_timestamps(quantity)
    manager
  end

  def self.product_list_seed_with_timestamps(quantity)
    seeds = product_list_seed_as_jsonb(quantity).as '"seeds"'
    op_timestamping = projected_timestamp(Time.now).as '"op_timestamping"'
    Arel::SelectManager.new.from(seeds).join(op_timestamping).on(create_true).project(
      seeds[:category_id],
      seeds[:name],
      seeds[:brand],
      op_timestamping[:datetime].as('"created_at"'),
      op_timestamping[:datetime].as('"updated_at"')
    )
  end

  def self.product_list_seed(quantity)
    category_count = Category.count
    raise 'No categories in catalog' unless category_count > 0
    seed_list = quantity.times.map do
      { category_id: (random_number(category_count) + 1),
        name: FFaker::Product.product,
        brand: FFaker::Product.brand }
    end.each_with_object({}) do |product_attributes, dictionary|
      dictionary[[product_attributes[:name], product_attributes[:brand]]] = product_attributes
    end.values
  end

  def self.product_list_seed_as_jsonb(quantity)
    jsonb = NamedFunction.new 'json_populate_recordset', [
      products_table_as_type,
      Quoted.new(ActiveSupport::JSON.encode(product_list_seed(quantity)))
    ]
    Arel::SelectManager.new.project(Arel.star).from jsonb
  end

  def self.products_table_as_type
    SqlLiteral.new "NULL::\"#{Product.table_name}\""
  end

  # Returns the `SELECT '2017-02-05 18:01:51.959677'::TIMESTAMP AS "datetime"` part:
  def self.projected_timestamp(timestamp = Time.now)
    timestamp_projection = SqlLiteral.new "#{casted_timestamp(timestamp).to_sql}::TIMESTAMP"
    Arel::SelectManager.new.project As.new(timestamp_projection, SqlLiteral.new('"datetime"'))
  end

  def self.casted_timestamp(timestamp = Time.now)
    # TODO: a way to not depend on a reference to an existing table (such as products in this case)
    # This was a similar solution, but instead of depending on the table, it depends on the
    # connection:
    # Arel::Nodes::Quoted.new ActiveRecord::Base.connection.quoted_date(timestamp)
    Casted.new timestamp, Product.arel_table[:created_at]
  end
end
