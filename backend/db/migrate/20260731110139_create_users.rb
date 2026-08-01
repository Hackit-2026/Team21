class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :notification_enabled

      t.timestamps
    end
  end
end
