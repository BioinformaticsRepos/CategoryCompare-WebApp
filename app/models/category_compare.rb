class CategoryCompare
  include ActiveModel::Model

  attr_accessor :diff_expressed_gene_lists, :gene_universe, :annotation_type, :organism_type, :significance_value, :list_of_gene_lists

  validates_presence_of :annotation_type, :significance_value, :organism_type, :gene_universe
  validates_numericality_of :significance_value, greater_than_or_equal_to: 0, message: 'Must be greater than or equal to 0'
  validates_numericality_of :significance_value, less_than_or_equal_to: 1, message: 'Must be be less than or equal to 1'

  def diff_expressed_gene_lists_attributes=(attributes)
    @diff_expressed_gene_lists = [DiffExpressedGeneList.new(attributes)]
  end

  # TODO Now that the list names gene_list.gene_list_label are used to refer to R variables,
  #      R command injection is possible. This should be fixed.
  # TODO Disallow commas in gene list names, since it can mess with the code I think.
  # TODO There should be an if statement here depending on the gene list.
  def run
    con = RserveUtils.get_connection()

    list_of_gene_lists = ""

    if gene_universe.gene_list.text_gene_list_used?() or gene_universe.gene_list.file_gene_list_used?()
      con.assign("EntrezUniverseTable", gene_universe.gene_list.to_r_gene_list())
      # TODO Should I use con.assign here?
      con.void_eval("geneUniverse <- unique(EntrezUniverseTable)" )
    else
      # TODO This state should never be allowed to happen in the first place.
      raise NotImplementedError("TODO No gene universe was specified. What should be done here?")
    end

    # TODO This list_of_gene_lists refers to the set of differentially-expressed genes, specified over a list of lists.
    self.diff_expressed_gene_lists.each_with_index do |de_gene_list, i|
      if de_gene_list.gene_list.text_gene_list_used?() or de_gene_list.gene_list.file_gene_list_used?()
        con.assign("genes#{i}", de_gene_list.gene_list.to_r_gene_list())
        con.void_eval("genelist#{i} <- list(genes=genes#{i}, universe=geneUniverse, annotation='org.#{self.organism_type}.eg.db')")
        list_of_gene_lists << "'#{de_gene_list.gene_list_label}'=genelist#{i},"
      end
    end

    # Removes trailing comma
    list_of_gene_lists.chomp!(',')

    con.void_eval("GeneLists <- list(#{list_of_gene_lists})")
    con.void_eval("GeneLists <- new('ccGeneList', GeneLists, ccType=c('#{self.annotation_type}'))")
    con.void_eval("fdr(GeneLists) <- 0")
    con.void_eval("EnrichedList <- ccEnrich(GeneLists)")
    con.void_eval("pvalueCutoff(EnrichedList)<-0.001")
    con.void_eval("ccOpts <- new('ccOptions', listNames=names(GeneLists), outType='none')")

    con.void_eval("ccResults<-ccCompare(EnrichedList, ccOpts)")
    
    elements = {}
    elements[:nodes] = []
    elements[:edges] = []

    r_nodes = con.eval("ccResults$#{self.annotation_type}@mainGraph@nodes").to_ruby
    r_edges = con.eval("ccResults$#{self.annotation_type}@mainGraph@edgeL").to_ruby
    r_weights = con.eval("ccResults$#{self.annotation_type}@mainGraph@edgeData@data").to_ruby
    r_node_data = con.eval("ccResults$#{self.annotation_type}@mainGraph@nodeData@data").to_ruby
    Rails.logger.debug r_node_data

    if (!r_nodes.nil?) && (r_nodes.length > 0)
      r_nodes.each_with_index {|node, index| elements[:nodes] << {data: {id: node, name: r_node_data[index]["Desc"]}}}
    else
      raise NotImplementedError("TODO No nodes were found. We should display an error/warning/something here.")
    end

    r_edges.each_with_index do |edge,i|
      if edge
        if edge[0].is_a? Array
          edge[0].each{|e| elements[:edges] << {data: {source: r_edges.key_at(i), target: r_nodes[e-1]}}}
        elsif edge[0].is_a? Integer
          elements[:edges] << {data: {source: r_edges.key_at(i),target: r_nodes[edge[0]-1]}}
        end
      end
    end

    elements[:edges].delete_if{|e| r_weights["#{e[:data][:source]}|#{e[:data][:target]}"][0] < self.significance_value.to_f}

    elements[:nodes].each {|n| n[:css] = {'background-color' => r_node_data[n[:data][:id]][15]}}
    elements
  end

  def initialize(attributes = {})
    self.diff_expressed_gene_lists = attributes[:diff_expressed_gene_lists]
    self.annotation_type = attributes[:annotation_type]
    self.organism_type = attributes[:organism_type]
    self.gene_universe = attributes[:gene_universe]
  end
end
