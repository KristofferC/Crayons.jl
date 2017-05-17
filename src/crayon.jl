const CSI = "\e["
const ESCAPED_CSI = "\\e["
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

struct ANSIColor
    r::Int # [0-9, 60-69], for 16 colors, 0-255 for 256 colors and 24 bit
    g::Int # [0-255] Only used for 24 bit colors
    b::Int # [0-255] Only used for 24 bit colors
    style::ColorMode
    active::Bool
    function ANSIColor(r::Int, g::Int = 0, b::Int = 0, style::ColorMode = COLORS_16, active = true)
        for v in (r, g, b)
            !(0 <= v <= 255) && throw(ArgumentError("Only colors between 0 and 255 allowed"))
        end
    return new(r, g, b, style, active)
    end
end


ANSIColor() = ANSIColor(0, 0, 0, COLORS_16, false)
ANSIColor(val::Int, style::ColorMode, active::Bool = true) = ANSIColor(val, 0, 0, style, active)

red(x::ANSIColor) = x.r
green(x::ANSIColor) = x.g
blue(x::ANSIColor) = x.b
val(x::ANSIColor) = x.r

# The inverse sets the color to default.
# No point making active if color already is default
Base.inv(x::ANSIColor) = ANSIColor(9, 0, 0, COLORS_16, x.active && !(x.style == COLORS_16 && x.r == 9))

struct ANSIStyle
    on::Bool
    active::Bool
end

ANSIStyle() = ANSIStyle(false, false)
ANSIStyle(v::Bool) = ANSIStyle(v, true)

# The inverse always sets the thing to false
# No point in setting active if the style is off.
Base.inv(x::ANSIStyle) = ANSIStyle(false, x.active && x.on)

struct Crayon
    fg::ANSIColor
    bg::ANSIColor

    reset::ANSIStyle
    bold::ANSIStyle
    faint::ANSIStyle
    italics::ANSIStyle
    underline::ANSIStyle
    blink::ANSIStyle
    negative::ANSIStyle
    conceal::ANSIStyle
    strikethrough::ANSIStyle
end

anyactive(x::Crayon) = ( (x.reset.active && x.reset.on) || x.fg.active        || x.bg.active    || x.bold.active     || x.faint.active   ||
                        x.italics.active || x.underline.active || x.blink.active || x.negative.active || x.conceal.active ||
                        x.strikethrough.active)

Base.inv(c::Crayon) = Crayon(inv(c.fg), inv(c.bg), ANSIStyle(), # no point taking inverse of reset,
                             inv(c.bold), inv(c.faint), inv(c.italics), inv(c.underline),
                             inv(c.blink), inv(c.negative), inv(c.conceal), inv(c.strikethrough))

function Base.print(io::IO, x::Crayon)
    if anyactive(x) && (Base.have_color || haskey(ENV, "FORCE_COLOR"))
        print(io, CSI)
        _print(io, x)
        print(io, END_ANSI)
    end
end

function Base.show(io::IO, x::Crayon)
    if anyactive(x)
        print(io, x)
        print(io, ESCAPED_CSI)
        _print(io, x)
        print(io, END_ANSI, CSI, "0", END_ANSI)
    end
end

function _parse_color(c::Union{Int, Symbol, NTuple{3,Int}})
    ansicol = ANSIColor()
    if c != :nothing
        if isa(c, Symbol)
            ansicol = ANSIColor(COLORS[c], COLORS_16)
        elseif isa(c, Int)
            ansicol = ANSIColor(c, COLORS_256)
        else
            ansicol = ANSIColor(c[1], c[2], c[3], COLORS_24BIT)
        end
    end
    return ansicol
end

function Crayon(;foreground::Union{Int, Symbol, NTuple{3,Int}} = :nothing,
                 background::Union{Int, Symbol, NTuple{3,Int}} = :nothing,
                 reset = :nothing,
                 bold = :nothing,
                 faint = :nothing,
                 italics = :nothing,
                 underline = :nothing,
                 blink = :nothing,
                 negative = :nothing,
                 conceal = :nothing,
                 strikethrough = :nothing)

    fgcol = _parse_color(foreground)
    bgcol = _parse_color(background)

    _reset         = ANSIStyle()
    _bold          = ANSIStyle()
    _faint         = ANSIStyle()
    _italics       = ANSIStyle()
    _underline     = ANSIStyle()
    _blink         = ANSIStyle()
    _negative      = ANSIStyle()
    _conceal       = ANSIStyle()
    _strikethrough = ANSIStyle()

    reset         != :nothing && (_reset         = ANSIStyle(reset        ))
    bold          != :nothing && (_bold          = ANSIStyle(bold         ))
    faint         != :nothing && (_faint         = ANSIStyle(faint        ))
    italics       != :nothing && (_italics       = ANSIStyle(italics      ))
    underline     != :nothing && (_underline     = ANSIStyle(underline    ))
    blink         != :nothing && (_blink         = ANSIStyle(blink        ))
    negative      != :nothing && (_negative      = ANSIStyle(negative     ))
    conceal       != :nothing && (_conceal       = ANSIStyle(conceal      ))
    strikethrough != :nothing && (_strikethrough = ANSIStyle(strikethrough))

    return Crayon(fgcol,
                  bgcol,
                  _reset,
                  _bold,
                  _faint,
                  _italics,
                  _underline,
                  _blink,
                  _negative,
                  _conceal,
                  _strikethrough)
end

# Prints the crayon without the inital and terminating ansi escape sequences
function _print(io::IO, c::Crayon)
    first_active = true
    if c.reset.active && c.reset.on
        first_active = false
        print(io, "0")
    end

    for (col, num) in ((c.fg, 30),
                       (c.bg, 40))
        if col.active
            !first_active && print(io, ";")
            first_active = false

            col.style == COLORS_16    && print(io, val(col) + num)
            col.style == COLORS_256   && print(io, num + 8, ";5;", val(col))
            col.style == COLORS_24BIT && print(io, num + 8, ";2;", red(col), ";", green(col), ";", blue(col))
        end
    end

    for (style, val) in ((c.bold         , 1),
                         (c.faint        , 2),
                         (c.italics      , 3),
                         (c.underline    , 4),
                         (c.blink        , 5),
                         (c.negative     , 7),
                         (c.conceal      , 8),
                         (c.strikethrough, 9))

        if style.active
            !first_active && print(io, ";")
            first_active = false

            style.on && print(io, val)
            # Bold off is actually 22 so special case for val == 1
            !style.on && print(io, val == 1 ? val + 21 : val + 20)
        end
    end
    return nothing
end

function Base.merge(a::Crayon, b::Crayon)
    fg            = b.fg.active            ? b.fg            : a.fg
    bg            = b.bg.active            ? b.bg            : a.bg
    reset         = b.reset.active         ? b.reset          : a.reset
    bold          = b.bold.active          ? b.bold          : a.bold
    faint         = b.faint.active         ? b.faint         : a.faint
    italics       = b.italics.active       ? b.italics       : a.italics
    underline     = b.underline.active     ? b.underline     : a.underline
    blink         = b.blink.active         ? b.blink         : a.blink
    negative      = b.negative.active      ? b.negative      : a.negative
    conceal       = b.conceal.active       ? b.conceal       : a.conceal
    strikethrough = b.strikethrough.active ? b.strikethrough : a.strikethrough

    return Crayon(fg,
                  bg,
                  reset,
                  bold,
                  faint,
                  italics,
                  underline,
                  blink,
                  negative,
                  conceal,
                  strikethrough)
end

Base.:*(a::Crayon, b::Crayon) = merge(a, b)

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
        print(buf, inv(crayon))
        print(io, String(take!(buf)))
    end
end

Base.print_with_color(crayon::Crayon, io::IO, msg::AbstractString...) =
    Base.with_output_color(print, crayon, io, msg...)
Base.print_with_color(crayon::Crayon, msg::AbstractString...) =
    print_with_color(crayon, STDOUT, msg...)
