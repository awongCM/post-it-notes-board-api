class AddXAndYCoordinatesToNotes < ActiveRecord::Migration[5.1]
  def up 
    add_column :notes, :x_coordinate, :integer
    add_column :notes, :y_coordinate, :integer
    Note.update_all(["x_coordinate = 0", "y_coordinate = 0"])
  end
  def down 
    remove_columns :notes, :x_coordinate, :y_coordinate
  end
end
