class Background < ActiveRecord::Base
  has_no_table
  belongs_to :category_compare
  column :gene_list, :string
  column :category_compare_id, :integer
end

  
