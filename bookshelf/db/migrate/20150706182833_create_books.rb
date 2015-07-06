class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.string :author
      t.date :published_on
      t.string :image_url
      t.text :description
      t.integer :user_id
      t.string :username

      t.timestamps null: false
    end
  end
end
