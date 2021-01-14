class CreateStirpeSubscriptions < ActiveRecord::Migration
  def change
    create_table :stirpe_subscriptions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :plan, index: true, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.string :subscription_id

      t.timestamps null: false
    end
  end
end
