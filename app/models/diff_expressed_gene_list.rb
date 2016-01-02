class DiffExpressedGeneList < ActiveRecord::Base
  has_no_table
  belongs_to :category_compare
  
  column :text_gene_list, :string
  column :file_gene_list, :string
  column :gene_list_label, :string
  column :color, :string
  column :category_compare_id, :integer
  
  validate :check_gene_list_presence
  validates_presence_of :gene_list_label, :color

#  def initialize(attrs = {})
    #@genelist = attrs[:genelist]
    #@type = attrs[:list_type]
  #end

  def check_gene_list_presence
    if text_gene_list.blank? and file_gene_list.blank?
      return false
    else
      return true
    end
  end

  def file_gene_list_source()
    self.file_gene_list.tempfile
  end

  def text_gene_list_used?()
    !text_gene_list.blank?
  end

  def file_gene_list_used?()
    File.exist?(file_gene_list_source()) and
      File.size(file_gene_list_source()) != 0
  end

  ##
  # Returns a string which represents this gene universe as
  # a list of integers, which can be interpreted by R.
  def to_r_gene_list()
    if text_gene_list_used?()
      self.text_gene_list.split(' ').map(&:to_i)
    elsif file_gene_list_used?()
      File.foreach(self.file_gene_list_source()).map{|line| line.to_i}
    else
      raise RuntimeError("Neither a text- or file-based gene list is available. R gene list can't be created.")
    end
  end

end
