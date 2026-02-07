class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.integer :year
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
