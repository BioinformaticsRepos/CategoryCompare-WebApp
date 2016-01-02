class GeneUniverse < ActiveRecord::Base
  has_no_table
  belongs_to :category_compare
  column :text_gene_list, :string
  column :file_gene_list, :string
  column :category_compare_id, :integer

  # TODO The notion that a model should only have one or the other of a text/file gene list is misleading.
  #      What I really need is a GeneList class. Then, a model will have a GeneList. And a GeneList can
  #      have either a file or text source.
  # TODO This class should probably be renamed to "GeneUniverse" to fit with the app's terminology.
  # TODO I should be able to say GeneUniverse.FromOrganism("Hs") or similar.

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

  ##
  # Returns a string which represents this gene universe as
  # a list of integers, which can be interpreted by R.
  def to_r_gene_list()
    if text_gene_list_used()
      self.text_gene_list.split(' ').map(&:to_i)
    elsif file_gene_list_used()
      File.foreach(self.file_gene_list_source()).map{|line| line.to_i}
    else
      raise RuntimeError("Neither a text- or file-based gene list is available. R gene list can't be created.")
    end
  end
end
