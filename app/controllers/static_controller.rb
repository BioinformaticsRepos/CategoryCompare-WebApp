class StaticController < ApplicationController
  def home
    @category_compare = CategoryCompare.new(datasets: [Dataset.new], background: Background.new)
    @organism_type_list = OrganismType.HumanFriendlyUIList
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
                                             background_attributes: [:gene_list], 
                                             datasets_attributes: [:name, :gene_list])

  end
end
