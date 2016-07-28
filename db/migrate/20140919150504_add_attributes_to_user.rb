class AddAttributesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :year_of_birth, :integer
    add_column :users, :zip_code, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
