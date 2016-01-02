class AllPossibleGenes < ActiveRecord::Base
  has_no_table
  belongs_to :category_compare
  column :text_gene_list, :string
  column :file_gene_list, :string
  column :category_compare_id, :integer

  ##
  # Returns the actual file behind the :file_gene_list field.
  def file_gene_list_source()
    self.file_gene_list.tempfile
  end

  def text_gene_list_used()
    self.text_gene_list.length > 0
  end

  def file_gene_list_used()
    !File.zero?(self.file_gene_list_source())
  end
end
