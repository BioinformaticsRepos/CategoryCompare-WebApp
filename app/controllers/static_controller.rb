class StaticController < ApplicationController
  def home
    @category_compare = CategoryCompare.new(diff_expressed_gene_list: [DiffExpressedGeneList.new],
                                            gene_universe: GeneUniverse.new)
    @organism_type_list = OrganismType.HumanFriendlyUIList
    @setting = Setting.new()
  end

  def update_graph
    @category_compare = CategoryCompare.new(graph_attributes)
    gon.elements = @category_compare.run

    render 'graph'
  end

  private
  def organism_type_db
    return OrganismType.english_to_db(organism_type)
  end
  
  private
  def graph_attributes
    params.require(:category_compare).permit(:annotation_type, :organism_type,
                                             :significance_value, 
                                             gene_universe_attributes: [:text_gene_list, :file_gene_list],
                                             diff_expressed_gene_list_attributes: [:gene_list_label, :text_gene_list, :file_gene_list])
  end
end
