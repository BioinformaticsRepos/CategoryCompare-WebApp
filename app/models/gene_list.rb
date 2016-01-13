##
# Represents a simple list of genes.
# The list of genes could come from a file, or a comma-separated string.
class GeneList
  include ActiveModel::Model

  attr_accessor :text_gene_list, :file_gene_list

  validates_presence_of :text_gene_list
  validates_presence_of :file_gene_list

  validate :check_consistency

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def file_gene_list_source()
    self.file_gene_list.tempfile
  end

  def text_gene_list_used?()
    !text_gene_list.blank?
  end

  def file_gene_list_used?()
    (not self.file_gene_list.nil?) and
      (not self.file_gene_list.tempfile.nil?) and
      (File.exist?(file_gene_list_source())) and
      (File.size(file_gene_list_source()) != 0)
  end

  ##
  # Returns a string which represents this gene universe as
  # a list of integers, which can be interpreted by R.
  def to_r_gene_list()
    # TODO I should probably add checks/assertions here to make sure that the associated gene list exists.
    # TODO It would better I think to say: if gene_list_type == GeneListType.text: rather than the current way. Currently, you have to add a new function for each new gene list type.
    if text_gene_list_used?()
      self.text_gene_list.split(' ').map(&:to_i)
    elsif file_gene_list_used?()
      File.foreach(self.file_gene_list_source()).map{|line| line.to_i}
    else
      # TODO Is it possible to prevent this state from ever occurring?
      raise RuntimeError("Neither a text- or file-based gene list is available. R gene list can't be created.")
    end
  end

  private
  def check_consistency
    unless text_gene_list_used?() ^ file_gene_list_used?()
      errors.add(:base, "Specify either a text- or file-based gene list, not both.")
    end
  end

end
