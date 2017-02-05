class CreateProductStats < ActiveRecord::Migration[5.0]
  def change
    create_table :product_stats, id: false do |t|
      t.references  :product,
                    null: false,
                    index: { name: :IX_product_stat },
                    foreign_key: { name: :FK_product_stat }

      t.integer     :rating,
                    null: false,
                    default: 0,
                    index: { name: :IX_product_rating }

      t.integer     :sell_count,
                    null: false,
                    default: 0,
                    index: { name: :IX_product_sell_count }

      t.timestamps
    end
  end
end
