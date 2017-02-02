class CreateInventoryStructures < ActiveRecord::Migration[5.0]
  def change
    create_table :shelves, comment: 'Where stuff is placed into' do |t|
      t.string   :name,
                 null: false,
                 index: { name: :UK_shelf_name, unique: true },
                 comment: 'A name used to physically identify the shelf'

      t.boolean  :warehouse,
                 null: false,
                 default: true,
                 comment: 'Whether the shelf is in the warehouse or not'
      t.timestamps
    end

    # Partial indexes on shelves:
    add_index :shelves, :warehouse, name: :IX_warehouse_shelf, where: 'warehouse = TRUE'
    add_index :shelves, :warehouse, name: :IX_counter_shelf, where: 'warehouse = FALSE'

    create_table :inbound_orders, comment: 'Registers any time stuff gets shipped into the store' do |t|
      t.text       :notes, comment: 'Notes about the incoming order'
      t.timestamps
    end

    create_table :inbound_order_transitions, comment: 'Inbound order state changes during the process' do |t|
      t.references :inbound_order,
                   null: false,
                   index: { name: :IX_transition_inbound_order },
                   foreign_key: { name: :FK_transition_inbound_order },
                   comment: 'The inbound process that changed state'

      t.string     :to_state,
                   null: false,
                   comment: 'The state into which the inbound process changed'

      t.boolean    :most_recent,
                   null: false,
                   comment: 'Whether this state change was the latest or not'

      t.integer    :sort_key,
                   null: false,
                   comment: 'A key that indicates the order of state changes'

      t.jsonb      :metadata,
                   default: {},
                   comment: 'Additional data about the state change'

      t.datetime   :created_at,
                   null: false,
                   comment: 'Timestamp of the state change'
    end

    # An index holding the order of transitions:
    add_index :inbound_order_transitions,
              [:inbound_order_id, :sort_key],
              unique: true,
              name: 'IX_inbound_order_transition_sort',
              comment: 'An index holding the order of transitions'

    # A partial index holding only references to the 'most_recent' record:
    add_index :inbound_order_transitions,
              [:inbound_order_id, :most_recent],
              unique: true,
              where: 'most_recent',
              name: 'IX_inbound_order_most_recent_transition',
              comment: 'A partial index holding only references to the most recent records of each inbound process'

    create_table :inbound_logs, comment: 'Details about what and how many stuff got stored into which shelf' do |t|
      t.references :inbound_order,
                   null: false,
                   index: { name: :IX_inbound_log_order },
                   foreign_key: { name: :FK_inbound_log_order },
                   comment: 'The inbound process that stored the incoming stuff'

      t.references :product,
                   null: false,
                   index: { name: :IX_inbound_log_product },
                   foreign_key: { name: :FK_inbound_log_product },
                   comment: 'The kind of stuff that got stored'

      t.references :shelf,
                   null: false,
                   index: { name: :IX_inbound_log_shelf },
                   foreign_key: { name: :FK_inbound_log_shelf },
                   comment: 'The shelf in which the stuff got stored'

      t.jsonb      :properties,
                   null: false,
                   default: {},
                   comment: 'Attributes of the stuff that got stored'

      t.integer    :quantity,
                   null: false,
                   default: 0,
                   comment: 'The quantity of stuff that got stored'

      t.timestamps
    end

    create_table :items, comment: 'All items that are or have been on inventory' do |t|
      t.references :inbound_log,
                   null: false,
                   index: { name: :IX_item_inbound_log },
                   foreign_key: { name: :FK_item_inbound_log },
                   comment: 'Reference to the inbound log that entered this item into inventory'

      t.references :product,
                   null: false,
                   index: { name: :IX_item_product },
                   foreign_key: { name: :FK_item_product },
                   comment: 'Reference to the product this item belongs to'

      t.references :shelf,
                   null: true,
                   index: { name: :IX_item_shelf },
                   foreign_key: { name: :FK_item_shelf },
                   comment: 'Reference to the shelf this item is currently placed into'

      t.integer    :shelf_rank,
                   null: true,
                   comment: 'Order in which this item is currently placed inside the shelf'

      t.jsonb      :properties,
                   null: false,
                   default: {},
                   comment: 'The current attributes for this item'

      t.boolean    :currently_available,
                   null: false,
                   default: true,
                   comment: 'Whether the item is currently present in our inventory or not'

      t.timestamps
    end

    # Partial indexes on items:
    add_index :items,
              :currently_available,
              name: :IX_available_item,
              where: 'currently_available = TRUE'

    add_index :items,
              :currently_available,
              name: :IX_sold_item,
              where: 'currently_available = FALSE'
  end
end
