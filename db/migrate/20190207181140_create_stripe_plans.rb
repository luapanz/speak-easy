class CreateStripePlans < ActiveRecord::Migration
  def change
    create_table :stripe_plans do |t|
      t.string :plan_id
      t.string :name

      t.timestamps null: false
    end
  end
end
