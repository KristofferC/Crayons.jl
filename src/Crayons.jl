module Crayons

export Crayon, CrayonStack, NormalCrayon, merge

const ESC = "\e["
const ESCAPED_ESC = "\\e["
const END_ANSI = "m"

# Add 30 to get fg ANSI
# Add 40 to get bg ANSI
const COLORS = Dict(
    :black         => 0,
    :red           => 1,
    :green         => 2,
    :yellow        => 3,
    :blue          => 4,
    :magenta       => 5,
    :cyan          => 6,
    :light_gray    => 7,
    :default       => 9,
    :dark_gray     => 60,
    :light_red     => 61,
    :light_green   => 62,
    :light_yellow  => 63,
    :light_blue    => 64,
    :light_magenta => 65,
    :light_cyan    => 66,
    :white         => 67
)

@enum(ColorMode,
RESET,
COLORS_16,
COLORS_256,
COLORS_24BIT)

immutable ANSIColor
    r::Int # [0-9, 60-69], for 16 colors, 0-255 for 256 colors and 24 bit
    g::Int # [0-255] Only used for 24 bit colors
    b::Int # [0-255] Only used for 24 bit colors
    style::ColorMode
    function ANSIColor(r::Int = 0, g::Int = 0, b::Int = 0, style::ColorMode = COLORS_16)
        for v in (r, g, b)
            !(0 <= v <= 255) && throw(ArgumentError("Only colors between 0 and 255 allowed"))
        end
    return new(r, g, b, style)
    end
end

ANSIColor(val::Int, style::ColorMode) = ANSIColor(val, 0, 0, style)


red(x::ANSIColor) = x.r
green(x::ANSIColor) = x.g
blue(x::ANSIColor) = x.b
val(x::ANSIColor) = x.r

immutable Crayon
    fg::ANSIColor
    bg::ANSIColor

    bold::Bool
    italics::Bool
    underline::Bool

    fg_active::Bool
    bg_active::Bool
    bold_active::Bool
    italics_active::Bool
    underline_active::Bool
end

anyactive(x::Crayon) = (x.fg_active || x.bg_active || x.bold_active ||
                        x.italics_active || x.underline_active)
(x::Crayon)(str...) = string(x, str...)
NormalCrayon() = Crayon(ANSIColor(0, RESET), ANSIColor(0, RESET), false, false, false, false, true, false, false, false)

function Base.print(io::IO, x::Crayon)
    if anyactive(x) && (Base.have_color || haskey(ENV, "FORCE_COLOR"))
        print(io, ESC)
        _print(io, x)
        print(io, END_ANSI)
    end
end

function Base.show(io::IO, x::Crayon)
    if anyactive(x)
        print(io, x)
        print(io, ESCAPED_ESC)
        _print(io, x)
        print(io, END_ANSI, ESC, "0", END_ANSI)
    end
end

function _parse_color(c::Union{Int, Symbol, NTuple{3,Int}})
    active = false
    ansicol = ANSIColor()
    if c != :nothing
        if isa(c, Symbol)
            ansicol = ANSIColor(COLORS[c], COLORS_16)
        elseif isa(c, Int)
            ansicol = ANSIColor(c, COLORS_256)
        else
            ansicol = ANSIColor(c[1], c[2], c[3], COLORS_24BIT)
        end
        active = true
    end
    return ansicol, active
end

function Crayon(;foreground::Union{Int, Symbol, NTuple{3,Int}} = :nothing,
                 background::Union{Int, Symbol, NTuple{3,Int}} = :nothing,
                 bold = :nothing, italics = :nothing, underline = :nothing)

    fgcol, fg_active = _parse_color(foreground)
    bgcol, bg_active = _parse_color(background)

    isbold = false
    bold_active = false

    isitalics = false
    italics_active = false

    isunderline = false
    underline_active = false

    if bold != :nothing; isbold = bold; bold_active = true; end
    if italics != :nothing; isitalics = italics; italics_active = true; end
    if underline != :nothing; isunderline = underline; underline_active = true; end

    return Crayon(fgcol, bgcol, isbold, isitalics, isunderline,
                  fg_active, bg_active, bold_active, italics_active, underline_active)
end

# Prints the crayon without the inital and terminating ansi escape sequences
function _print(io::IO, c::Crayon)
    if c.fg.style == RESET
        print(io, ";0")
        return
    end
    first_active = true
    for (col, active, num) in ((c.fg, c.fg_active, 30),
                               (c.bg, c.bg_active, 40))
        if active
            !first_active && print(io, ";")
            first_active = false

            col.style == COLORS_16    && print(io, val(col) + num)
            col.style == COLORS_256   && print(io, num + 8, ";5;", val(col))
            col.style == COLORS_24BIT && print(io, num + 8, ";2;", red(col), ";", green(col), ";", blue(col))
        end
    end

    for (style, active, val) in ((c.bold, c.bold_active, 1),
                                 (c.italics, c.italics_active, 3),
                                 (c.underline, c.underline_active, 4))
        if active
            !first_active && print(io, ";")
            first_active = false

            style  && print(io, val)
            !style && print(io, val + 20)
        end
    end
    return nothing
end

function Base.merge(a::Crayon, b::Crayon)
    fg        = b.fg_active        ? b.fg        : a.fg
    bg        = b.bg_active        ? b.bg        : a.bg
    bold      = b.bold_active        ? b.bold      : a.bold
    italics   = b.italics_active   ? b.italics   : a.italics
    underline = b.underline_active ? b.underline : a.underline
    fg_active = a.fg_active || b.fg_active
    bg_active = a.bg_active || b.bg_active

    bold_active      = a.bold_active      || b.bold_active
    italics_active   = a.italics_active   || b.italics_active
    underline_active = a.underline_active || b.underline_active

    return Crayon(fg, bg, bold, italics, underline, fg_active, bg_active, bold_active,
                  italics_active, underline_active)
end

function Base.merge(toks::Crayon...)
    if length(toks) == 0
        return Crayon()
    end
    tok = toks[1]
    for i in 2:length(toks)
        tok = merge(tok, toks[i])
    end
    return tok
end

function Base.with_output_color(f::Function, crayon::Crayon, io::IO, args...)
    buf = IOBuffer()
    print(buf, crayon)
    try f(buf, args...)
    finally
        print(buf, NormalCrayon())
        print(io, takebuf_string(buf))
    end
end

Base.print_with_color(crayon::Crayon, io::IO, msg::AbstractString...) =
    Base.with_output_color(print, crayon, io, msg...)
Base.print_with_color(crayon::Crayon, msg::AbstractString...) =
    print_with_color(crayon, STDOUT, msg...)

include("crayon_stack.jl")
include("test_prints.jl")
include("logo.jl")
end # module

