class DiffExpressedGeneList
  include ActiveModel::Model
  
  attr_accessor :gene_list_label, :color, :category_compare_id, :gene_list
  
  validate :check_gene_list_presence
  validates_presence_of :gene_list_label, :color

  def gene_list_attributes=(attributes)
    @gene_list = GeneList.new(attributes)
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def check_gene_list_presence
    if gene_list.text_gene_list.blank? and gene_list.file_gene_list.blank?
      return false
    else
      return true
    end
  end

end
