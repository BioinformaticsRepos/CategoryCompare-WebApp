# TODO Add a class for organisms here.
class OrganismType
  ### Bioconductor database packages. ###
  DB_HUMAN = "Hs"
  DB_MOUSE = "Mm"
  DB_RAT = "Rn"
  DB_FLY = "Dm"
  DB_ZEBRA_FISH = "Dr"
  DB_AFRICAN_CLAWED_FROG = "Xl"
  DB_BOVINE = "Bt"
# TODO QUESTION What is Sg? A typo? I don't see a bioconductor package for org.Sg.eg.db.
#Sg

  ### Human-readable organism names. ###
  ENGLISH_HUMAN = "Human"
  ENGLISH_MOUSE = "Mouse"
  ENGLISH_RAT = "Rat"
  ENGLISH_FLY = "Fly"
  ENGLISH_ZEBRA_FISH = "Zebrafish"
  ENGLISH_AFRICAN_CLAWED_FROG = "African clawed frog"
  ENGLISH_BOVINE = "Bovine"

  # TODO Refactor this code so that OrganismType is a class with properties EnglishName, ScientificName, BioconductorDBPackage? And then return a list of these?
  # TODO Add methods for converting to/from these names.
  # TODO Would a project to make provide an easy way to access these organism names, and scientific names, built into the language itself, be a useful addition?

  ### Scientific organism names. ###
  SCI_HUMAN = "Homo sapiens"
  SCI_MOUSE = "Mus musculus"
  SCI_RAT = "Rattus norvegicus"
  SCI_FLY = "Drosophilia melanogaster"
  SCI_ZEBRA_FISH = "Danio rerio"
  SCI_AFRICAN_CLAWED_FROG = "Xenopus laevis"
  SCI_BOVINE = "Bos taurus"

  cattr_accessor :HumanFriendlyList
  @@HumanFriendlyList = [ENGLISH_HUMAN               + " (" + SCI_HUMAN + ")",
                         ENGLISH_MOUSE               + " (" + SCI_MOUSE + ")",
                         ENGLISH_RAT                 + " (" + SCI_RAT + ")",
                         ENGLISH_FLY                 + " (" + SCI_FLY + ")",
                         ENGLISH_ZEBRA_FISH          + " (" + SCI_ZEBRA_FISH + ")",
                         ENGLISH_AFRICAN_CLAWED_FROG + " (" + SCI_AFRICAN_CLAWED_FROG + ")",
                         ENGLISH_BOVINE              + " (" + SCI_BOVINE + ")"]

  cattr_accessor :HumanFriendlyUIList
  @@HumanFriendlyUIList = [[ENGLISH_HUMAN               + " (" + SCI_HUMAN + ")", DB_HUMAN],
                           [ENGLISH_MOUSE               + " (" + SCI_MOUSE + ")", DB_MOUSE],
                           [ENGLISH_RAT                 + " (" + SCI_RAT + ")", DB_RAT],
                           [ENGLISH_FLY                 + " (" + SCI_FLY + ")", DB_FLY],
                           [ENGLISH_ZEBRA_FISH          + " (" + SCI_ZEBRA_FISH + ")", DB_ZEBRA_FISH],
                           [ENGLISH_AFRICAN_CLAWED_FROG + " (" + SCI_AFRICAN_CLAWED_FROG + ")", DB_AFRICAN_CLAWED_FROG],
                           [ENGLISH_BOVINE              + " (" + SCI_BOVINE + ")", DB_BOVINE]]


  def self.english_to_db(organism_type)
      case organism_type
      when ENGLISH_HUMAN
        return DB_HUMAN
      when ENGLISH_MOUSE
        return DB_MOUSE
      when ENGLISH_RAT
        return DB_RAT
      when ENGLISH_FLY
        return DB_FLY
      when ENGLISH_ZEBRA_FISH
        return DB_ZEBRA_FISH
      when ENGLISH_AFRICAN_CLAWED_FROG
        return DB_AFRICAN_CLAWED_FROG
      when ENGLISH_BOVINE
        return DB_BOVINE
      else
        return "TODO THROW AN ERROR HERE"
      end
  end
end
