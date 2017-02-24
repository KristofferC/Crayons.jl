__precompile__(true)

module Crayons

export Crayon, CrayonStack, merge
using Compat

include("crayon.jl")
include("crayon_stack.jl")
include("crayon_wrapper.jl")
include("test_prints.jl")
include("logo.jl")
include("consts.jl")

end # module

