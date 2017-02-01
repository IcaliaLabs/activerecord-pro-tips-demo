class CreateCatalogStructures < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end

    create_table :products do |t|
      t.references :category, foreign_key: true
      t.string :name
      t.string :brand
      t.timestamps
    end
  end
end
