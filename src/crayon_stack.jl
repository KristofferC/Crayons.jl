# Type for pushing and popping text states
immutable CrayonStack
    crayons::Vector{Crayon}
end

Base.print(io::IO, cs::CrayonStack) = print(io, cs.crayons[end])

# Defaults to everything enabled and default
function CrayonStack()
    CrayonStack([Crayon(ANSIColor(9, COLORS_16),
                        ANSIColor(9, COLORS_16),
                        false, false, false,
                        true, true, true, true, true)])
end

function Base.push!(cs::CrayonStack, c::Crayon)
    pc = cs.crayons[end]
    c_new = Crayon(c.fg_active        ? c.fg        : pc.fg,
                   c.bg_active        ? c.bg        : pc.bg,
                   c.bold_active      ? c.bold      : pc.bold,
                   c.italics_active   ? c.italics   : pc.italics,
                   c.underline_active ? c.underline : pc.underline,
                   true, true, true, true, true)
    push!(cs.crayons, c_new)
    return cs
end

function Base.pop!(cs::CrayonStack)
    pop!(cs.crayons)
    # Return the currently active crayon so we can use print(pop!(crayonstack), "bla")
    return cs
end
