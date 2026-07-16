struct CrayonWrapper
    c::Crayon
    v::Vector{Union{CrayonWrapper,String}}
end

function (c::Crayon)(args::Union{CrayonWrapper,AbstractString}...)
    values = Vector{Union{CrayonWrapper,String}}(undef, length(args))
    for i in eachindex(args)
        arg = args[i]
        values[i] = arg isa CrayonWrapper ? arg : String(arg)
    end
    CrayonWrapper(c, values)
end

Base.show(io::IO, cw::CrayonWrapper) = _show(io, cw, CrayonStack(incremental = true))

_show(io::IO, str::String, stack::CrayonStack) = print(io, str)

function _show(io::IO, cw::CrayonWrapper, stack::CrayonStack)
    print(io, push!(stack, cw.c))
    for obj in cw.v
        _show(io, obj, stack)
    end
    length(stack.crayons) > 1 && print(io, pop!(stack))
    return
end

Base.:*(c::Crayon, cw::CrayonWrapper) = CrayonWrapper(c * cw.c, cw.v)
Base.:*(cw::CrayonWrapper, c::Crayon) = CrayonWrapper(cw.c * c, cw.v)

# Concatenation; the crayon applies to the string it is multiplied with
Base.:*(c::Crayon, s::AbstractString) = c(s)
Base.:*(s::AbstractString, cw::CrayonWrapper) = CrayonWrapper(Crayon(), Union{CrayonWrapper,String}[String(s), cw])
Base.:*(cw::CrayonWrapper, s::AbstractString) = CrayonWrapper(Crayon(), Union{CrayonWrapper,String}[cw, String(s)])
Base.:*(a::CrayonWrapper, b::CrayonWrapper) = CrayonWrapper(Crayon(), Union{CrayonWrapper,String}[a, b])
