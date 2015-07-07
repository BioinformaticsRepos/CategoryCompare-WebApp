class Dataset < ActiveRecord::Base
  has_no_table
  belongs_to :category_compare
  
  column :gene_list, :string
  column :name, :string
  column :color, :string
  column :category_compare_id, :integer
  
  validates_presence_of :gene_list, :name, :color

  
#  def initialize(attrs = {})
    #@genelist = attrs[:genelist]
    #@type = attrs[:list_type]
  #end
end

