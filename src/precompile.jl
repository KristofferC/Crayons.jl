function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    crayon"red"
    print(IOBuffer(), Crayon(foreground = :red), "In red. ", Crayon(bold = true), "Red and bold")
    precompile(Tuple{typeof(Base.print), Base.TTY, Crayons.Crayon})
end

_precompile_()
