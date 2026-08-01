class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :store, null: false, foreign_key: true
      t.string :name
      t.string :image_url
      t.integer :original_price
      t.integer :discount_price
      t.integer :quantity
      t.string :category
      t.datetime :sale_end_at
      t.integer :status

      t.timestamps
    end
  end
end
