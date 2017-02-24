__precompile__(true)

module Crayons

export Crayon, CrayonStack, merge

include("crayon.jl")
include("crayon_stack.jl")
include("test_prints.jl")
include("logo.jl")
include("consts.jl")

end # module

