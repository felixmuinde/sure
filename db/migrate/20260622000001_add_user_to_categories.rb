class AddUserToCategories < ActiveRecord::Migration[7.2]
  def change
    add_reference :categories, :user, type: :uuid, null: false, foreign_key: true

    remove_index :categories, %i[family_id name], unique: true if index_exists?(:categories, %i[family_id name], unique: true)
    add_index    :categories, %i[family_id user_id name], unique: true
  end
end
