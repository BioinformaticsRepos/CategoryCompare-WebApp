class GeneUniverse 
  include ActiveModel::Model

  ##
  # The actual list of genes that make up this gene universe.
  attr_accessor :gene_list
  validates_presence_of :gene_list

  def from_organism(organism_type)
    # TODO I should be able to say GeneUniverse.FromOrganism("Hs") or similar.
    raise NotImplementedError("TODO Add this code.")
  end

  def gene_list_attributes=(attributes)
    @gene_list = GeneList.new(attributes)
  end


  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
