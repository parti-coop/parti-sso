class AddNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nickname, :string, null: true
    add_index :users, :nickname, unique: true
    reversible do |dir|
      dir.up do
        query = 'UPDATE users SET nickname = id'
        ActiveRecord::Base.connection.execute query
        say query

        change_column_null :users, :nickname, false
      end
    end
  end
end
