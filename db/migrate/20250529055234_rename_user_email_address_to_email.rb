class RenameUserEmailAddressToEmail < ActiveRecord::Migration[8.0]
  def up
    rename_column :users, :email_address, :email
    rename_index :users, :index_users_on_email_address, :index_users_on_email
  end

  def down
    rename_index :users, :index_users_on_email, :index_users_on_email_address
    rename_column :users, :email, :email_address
  end
end
