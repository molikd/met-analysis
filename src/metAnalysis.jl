module metAnalysis

#import PopGen
#import GeneticVariation

# basic internals
include("changeConf.jl")
include("metAPIcalls.jl")
include("metPopulate.jl")

# analysis
include("globalDiversity.jl")

end # module
