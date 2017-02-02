class CreateCatalogStructures < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false, index: { name: :UK_category_name, unique: true }
      t.timestamps
    end

    create_table :products do |t|
      t.references :category,
                   null: false,
                   index: { name: :IX_product_category },
                   foreign_key: { name: :FK_product_category }

      t.string     :name,  null: false, index: { name: :IX_product_name }
      t.string     :brand, null: false, index: { name: :IX_product_brand }

      t.timestamps
    end
    add_index :products, [:name, :brand], name: :UK_brand_product_name, unique: true
  end
end
