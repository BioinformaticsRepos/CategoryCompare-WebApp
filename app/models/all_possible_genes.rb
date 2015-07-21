class AllPossibleGenes < ActiveRecord::Base
  has_no_table
  belongs_to :category_compare
  column :text_gene_list, :string
  column :file_gene_list, :string
  column :category_compare_id, :integer
end
