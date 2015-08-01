class CategoryCompare < ActiveRecord::Base
  has_no_table
  require 'rserve'

  has_many :diff_expressed_gene_list
  has_one :all_possible_genes
  accepts_nested_attributes_for :diff_expressed_gene_list, :all_possible_genes

  column :annotation_type, :string
  column :organism_type, :string
  column :significance_value, :real

  validates_presence_of :annotation_type, :significance_value, :organism_type
  validates_numericality_of :significance_value, greater_than_or_equal_to: 0, message: 'Must be greater than or equal to 0'
  validates_numericality_of :significance_value, less_than_or_equal_to: 1, message: 'Must be be less than or equal to 1'

  def run
    con=Rserve::Connection.new
    # TODO This substring is a giant hack. I need a controller that makes a list to be displayed in the UI, and I need to
    #      get the selected organism_type from that controller - not the selected UI text.
    con.void_eval("library('org.#{self.organism_type}.eg.db')")
    # TODO There should be an if statement here depending on the gene list.
    if self.all_possible_genes.text_gene_list.length > 0
      con.assign("EntrezUniverseTable", self.all_possible_genes.text_gene_list.split(' ').map(&:to_i))
    elsif !File.zero?(self.all_possible_genes.file_gene_list.tempfile)
      con.assign("EntrezUniverseTable", File.foreach(self.all_possible_genes.file_gene_list.tempfile).map{|line| line.to_i})
#self.all_possible_genes.file_gene_list.read().lines.map(&:to_i))
    end

    con.void_eval("geneUniverse <- unique(EntrezUniverseTable)" )

    # TODO This list_of_gene_lists refers to the set of differentially-expressed genes, specified over a list of lists.
    list_of_gene_lists = ""
    self.diff_expressed_gene_list.each_with_index do |set, i|
      # TODO This validation should be more rigorous, correct.
      if !set.text_gene_list.blank?
        con.assign("genes#{i}", set.text_gene_list.split(' ').map(&:to_i))
        con.void_eval("genelist#{i} <- list(genes=genes#{i}, universe=geneUniverse, annotation='org.#{self.organism_type}.eg.db')")
        list_of_gene_lists << "LEVEL#{i}=genelist#{i},"
      elsif not File.zero?(set.file_gene_list.tempfile)
        con.assign("genes#{i}", File.foreach(set.file_gene_list.tempfile).map{|line| line.to_i})
        con.void_eval("genelist#{i} <- list(genes=genes#{i}, universe=geneUniverse, annotation='org.#{self.organism_type}.eg.db')")
        # TODO This should be renamed "list_of_diff_expressed_gene_lists"
        list_of_gene_lists << "LEVEL#{i}=genelist#{i},"
      end
    end

    # TODO The reason the "Organism type" IS UNREADable is because we use it
    #      to say 'org.{Organism type}.db' to get info about it. There should be
    #      a data structure mapping from an organism type to a human-readable name.
    #      Same for the databases and such.
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

    r_nodes.each_with_index {|node, index| elements[:nodes] << {data: {id: node, name: r_node_data[index]["Desc"]}}}

    r_edges.each_with_index do |edge,i|
      if edge
        if edge[0].is_a? Array
          edge[0].each{|e| elements[:edges] << {data: {source: r_edges.key_at(i),target: r_nodes[e-1]}}}
        elsif edge[0].is_a? Integer
          elements[:edges] << {data: {source: r_edges.key_at(i),target: r_nodes[edge[0]-1]}}
        end
      end
    end

    elements[:edges].delete_if{|e| r_weights["#{e[:data][:source]}|#{e[:data][:target]}"][0] < self.significance_value.to_f}

    elements[:nodes].each {|n| n[:css] = {'background-color' => r_node_data[n[:data][:id]][15]}}
    elements
  end
end
