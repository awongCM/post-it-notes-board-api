class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :title
      t.string :content
      t.string :color

      t.timestamps
    end
  end
end
