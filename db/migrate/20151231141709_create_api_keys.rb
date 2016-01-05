class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.references :user, null: false
      t.string :digest, null: false
      t.string :server, null: false, index: true
      t.string :client, null: false, index: true
      t.datetime :expires_at, null: false
      t.datetime :last_access_at, null: false
      t.boolean :is_locked, null: false, default: false
      t.timestamps null: false
    end

    add_index :api_keys, [:user_id, :client, :server], unique: true
  end
end
