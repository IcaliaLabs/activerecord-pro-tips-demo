# = InboundInventoryStorer
# Service that stores the inventory from an InboundOrder. Called during the order transition to
# a 'completed' state.
class InboundInventoryStorer
  attr_reader :order, :timestamp

  def initialize(given_inbound_order)
    raise 'Given order is not yet received' if given_inbound_order.pending?
    raise 'Given order is already completed' if given_inbound_order.completed?
    @order = given_inbound_order
  end

  def store_order_items!
    @timestamp = Time.now

    # Execute the “INSERT” command:
    ActiveRecord::Base.connection.insert store_order_items_insert_manager.to_sql
  end

  protected

  def logs_table
    @logs_table ||= InboundLog.arel_table
  end

  def items_table
    @items_table ||= Item.arel_table
  end

  def shelves_table
    @shelves_table ||= Shelf.arel_table
  end

  def timestamp_quoted
    Arel::Nodes::Quoted.new ActiveRecord::Base.connection.quoted_date(timestamp)
  end

  def timestamp_as_projection(alias_name)
    Arel::Nodes::As.new timestamp_quoted, Arel::Nodes::SqlLiteral.new("\"#{alias_name}\"")
  end

  def order_logs
    logs_table.where logs_table[:inbound_order_id].eq(order.id)
  end

  # Generates SQL: 'generate_series(1, "inbound_logs"."quantity")'
  def order_logs_item_sort
    Arel::Nodes::NamedFunction.new 'generate_series', [1, logs_table[:quantity]]
  end

  # Returns an Arel object with an interesting projection that multiplies each
  # inbound_log by it's quantity, resulting in a number of rows directly
  # mappable/insertable to Item rows:
  #
  # TODO: Is ActiveRecord still doing it's nasty thing with scope id param?
  # If not, I'd like this method to be in the InboundLog model instead...
  def inbound_logs_as_line_items_projection
    order_logs.project \
      logs_table[:id].as('"inbound_log_id"'),
      logs_table[:product_id],
      logs_table[:properties],
      logs_table[:shelf_id],
      order_logs_item_sort.as('"log_item_sort_order"')
  end

  # Returns an Arel object with an projection of shelf ids and it's respective:
  # item count:
  def shelves_item_counts_projection
    join_condition = logs_table[:shelf_id].eq items_table[:shelf_id]
    order_logs
      .join(items_table, Arel::Nodes::OuterJoin)
      .on(join_condition)
      .group(logs_table[:shelf_id])
      .project \
        logs_table[:shelf_id],
        items_table[Arel.star].count.as('"item_count"')
  end

  # Crazy stuff:
  def self.inbounding_items_rank_in_shelf
    shelves_item_counts = Arel::Table.new :shelves_item_counts
    inbound_logs_as_line_items = Arel::Table.new :inbound_logs_as_line_items

    # Generate the '(
    #   PARTITION BY "inbound_logs_as_line_items"."shelf_id"
    #   ORDER BY "inbound_logs_as_line_items"."inbound_log_id",
    #            "inbound_logs_as_line_items"."log_item_sort_order"
    # )' part:
    partitioned_row_numbers = Arel::Nodes::Window.new
    partitioned_row_numbers.partition inbound_logs_as_line_items[:shelf_id]
    partitioned_row_numbers.order inbound_logs_as_line_items[:inbound_log_id],
                                  inbound_logs_as_line_items[:log_item_sort_order]

    # Generate the 'row_number() OVER (PARTITION...)' part:
    ranking_order = Arel::Nodes::Over.new \
      Arel::Nodes::NamedFunction.new('row_number', []),
      partitioned_row_numbers

    # Return the ranking_order + "shelves_item_counts"."item_count" node:
    Arel::Nodes::Addition.new ranking_order, shelves_item_counts[:item_count]
  end

  delegate :inbounding_items_rank_in_shelf, to: :class

  def stored_items_projection
    inbound_logs_as_line_items = inbound_logs_as_line_items_projection
      .as '"inbound_logs_as_line_items"'

    shelves_item_counts = shelves_item_counts_projection.as '"shelves_item_counts"'

    order_logs
      .join(inbound_logs_as_line_items)
      .on(logs_table[:id].eq(inbound_logs_as_line_items[:inbound_log_id]))
      .join(shelves_item_counts)
      .on(inbound_logs_as_line_items[:shelf_id].eq(shelves_item_counts[:shelf_id]))
      .project \
        inbound_logs_as_line_items[:inbound_log_id],
        inbound_logs_as_line_items[:product_id],
        inbound_logs_as_line_items[:properties],
        inbound_logs_as_line_items[:shelf_id],
        inbounding_items_rank_in_shelf.as('"shelf_rank"'),
        timestamp_as_projection('created_at'),
        timestamp_as_projection('updated_at')
  end

  def store_order_items_insert_manager
    insert_manager = Arel::InsertManager.new
    insert_manager.into items_table

    # Genera la lista de columnas del insert:
    insert_manager.columns.concat [
      items_table[:inbound_log_id],
      items_table[:product_id],
      items_table[:properties],
      items_table[:shelf_id],
      items_table[:shelf_rank],
      items_table[:created_at],
      items_table[:updated_at]
    ]

    # agrega el “SELECT”:
    insert_manager.select stored_items_projection
    insert_manager
  end
end
