class Setting < ActiveRecord::Base
  has_no_table

  column :bg_color, :string

  def initialize_settings
    self.bg_color = "#FFFFFF"
  end
end
