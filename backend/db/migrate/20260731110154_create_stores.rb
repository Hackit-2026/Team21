class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :address
      t.float :latitude
      t.float :longitude
      t.string :business_hours

      t.timestamps
    end
  end
end
