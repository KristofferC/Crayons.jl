function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    @info "precompiling..."
    precompile(Tuple{Crayons.var"#@crayon_str", LineNumberNode, Module, String})
    precompile(Tuple{typeof(Crayons._parse_color_string), Base.SubString{String}})
    precompile(Tuple{Type{Crayons.Crayon}, Crayons.ANSIColor, Crayons.ANSIColor, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle, Crayons.ANSIStyle})
    precompile(Tuple{typeof(Base.print), Base.TTY, Crayons.Crayon})
    precompile(Tuple{typeof(Base.print), Base.IOBuffer, Crayons.Crayon})
    precompile(Tuple{Type{Crayons.ANSIStyle}, Bool})
end

_precompile_()
