class AddUserToBudgets < ActiveRecord::Migration[7.2]
  def change
    add_reference :budgets, :user, type: :uuid, null: false, foreign_key: true

    remove_index :budgets, %i[family_id start_date end_date], unique: true
    add_index    :budgets, %i[family_id user_id start_date end_date], unique: true
  end
end
