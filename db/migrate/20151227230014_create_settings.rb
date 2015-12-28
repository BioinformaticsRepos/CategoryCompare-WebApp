class CreateSettings < ActiveRecord::Migration
  def change
    create_table :setting do |t|
      t.string :bg_color

      t.timestamps
    end
  end
end
