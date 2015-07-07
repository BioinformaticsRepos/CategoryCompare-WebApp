class CategoryCompare < ActiveRecord::Base
  has_no_table
  require 'rserve'

  has_many :datasets
  has_one :background
  accepts_nested_attributes_for :datasets, :background

  column :annotation_type, :string
  column :organism_type, :string
  column :significance_value, :real
  
  validates_presence_of :annotation_type, :significance_value, :organism_type
  validates_numericality_of :significance_value, greater_than_or_equal_to: 0, message: 'Must be greater than or equal to 0'
  validates_numericality_of :significance_value, less_than_or_equal_to: 1, message: 'Must be be less than or equal to 1'


  def run
      con=Rserve::Connection.new
      con.void_eval("library('categoryCompare')")
      con.void_eval("library('org.#{self.organism_type}.eg.db')")
      con.void_eval("library('GO.db')")
      con.void_eval("library('KEGG.db')")
      con.assign("EntrezUniverseTable", self.background.gene_list.split(' ').map(&:to_i))
      con.void_eval("geneUniverse <- unique(EntrezUniverseTable)" )

      list_of_gene_lists = ""
      self.datasets.each_with_index do |set, i|
        con.assign("genes#{i}", set.gene_list.split(' ').map(&:to_i))
        con.void_eval("genelist#{i} <- list(genes=genes#{i}, universe=geneUniverse, annotation='org.#{self.organism_type}.eg.db')")
        list_of_gene_lists << "LEVEL#{i}=genelist#{i},"
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

      r_nodes.each {|n| elements[:nodes] << {data: {id: n,name:n}}}

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
