class Setting < ActiveRecord::Base
  has_no_table

  column :bg_color, :string
  column :edge_color, :string

  def initialize_settings
    self.bg_color = "#FFFFFF"
    self.edge_color = "#FFFFFF"
  end
end
