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

    product_ids = []

    if quantity < 5
      product_ids = mass_create.call
    else
      Rails.logger.silence { product_ids = mass_create.call }
    end
    create_missing_product_stats_with_random_values
  end

  def self.upsert_product_stats_with_random_values
    update_product_stats_with_random_values && create_missing_product_stats_with_random_values
  end

  def self.update_product_stats_with_random_values
    product_stats = ProductStat.arel_table
    updated_stats = products_projected_as_random_stats.as '"updated_stats"'
    manager = Arel::UpdateManager.new
    manager.table(product_stats).set ([:product_id, :rating, :sell_count, :updated_at].map do |name|
      [product_stats[name], updated_stats[name]]
    end)
    manager.where product_stats[:product_id].eq(updated_stats[:product_id])
    update, conditions = manager.to_sql.split 'WHERE'
    execute [update, "FROM #{updated_stats.to_sql} WHERE", conditions].join
  end

  def self.create_missing_product_stats_with_random_values
    results = execute "#{random_product_stats_insertion.to_sql} RETURNING product_id",
                      'Product Stat Create'
    results.to_a.map { |result| result['product_id'] }
  end

  def self.random_product_stats_insertion
    products, stats = [Product, ProductStat].map(&:arel_table)
    manager = create_insert.into stats
    manager.select products_projected_as_random_stats.join(stats, OuterJoin)
                                                     .on(products[:id].eq(stats[:product_id]))
                                                     .having(stats[Arel.star].count.lt(1))
    manager
  end

  # Generates the following query:
  # SELECT
  #   "products"."id" AS "product_id",
  #   round(random() * 5) AS "rating",
  #   round(random() * 10000) AS "sell_count"
  # FROM "products"
  def self.products_projected_as_random_stats(timestamp = Time.now)
    products = Product.arel_table
    timestamping = projected_timestamp(timestamp).as '"op_timestamping"'
    products.join(timestamping)
            .on(create_true)
            .group(products[:id], timestamping[:datetime])
            .project products[:id].as('"product_id"'),
                     NamedFunction.new('round', [SqlLiteral.new('random() * 5')], '"rating"'),
                     NamedFunction.new('round', [SqlLiteral.new('random() * 10000')], '"sell_count"'),
                     timestamping[:datetime].as('"created_at"'),
                     timestamping[:datetime].as('"updated_at"')
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
