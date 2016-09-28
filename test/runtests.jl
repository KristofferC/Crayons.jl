using Crayons
using Crayons.Box
using Base.Test


withenv("FORCE_COLOR" => true) do

Crayons.print_logo()

# Styles
@test string(Crayon(bold = true)) == "\e[1m"
@test string(Crayon(bold = false)) == "\e[22m"
@test string(Crayon(underline = true)) == "\e[4m"
@test string(Crayon(underline = false)) == "\e[24m"
@test string(Crayon(bold = true, underline = false)) == "\e[1;24m"
@test string(Crayon(italics = false)) == "\e[23m"
@test string(Crayon(italics = true, underline = false)) == "\e[3;24m"
@test string(Crayon(faint = true)) == "\e[2m"
@test string(Crayon(conceal = true)) == "\e[8m"
@test string(Crayon(faint = false)) == "\e[22m"
@test string(Crayon(conceal = false)) == "\e[28m"
@test string(Crayon(strikethrough = true)) == "\e[9m"
@test string(Crayon(blink = true)) == "\e[5m"
@test string(Crayon(strikethrough = false)) == "\e[29m"
@test string(Crayon(blink = false)) == "\e[25m"
@test string(Crayon(negative = true)) == "\e[7m"
@test string(Crayon(negative = false)) == "\e[27m"
@test string(Crayon(reset = true)) == "\e[0m"
@test string(Crayon(reset = false)) == ""
@test string(Crayon()) == ""

# 16 colors
@test string(Crayon(foreground = :red)) == "\e[31m"
@test string(Crayon(background = :green)) == "\e[42m"
@test string(Crayon(foreground = :red, background = :green)) == "\e[31;42m"
@test string(Crayon(foreground = :red, bold = true)) == "\e[31;1m"
@test string(Crayon(foreground = :default, background = :default)) == "\e[39;49m"

# 256 colors
@test string(Crayon(foreground = 32)) == "\e[38;5;32m"
@test string(Crayon(foreground = 32, bold = true)) == "\e[38;5;32;1m"
@test string(Crayon(foreground = 32, background = 15, bold = true)) == "\e[38;5;32;48;5;15;1m"

# 24 bit colors
@test string(Crayon(foreground = (100,150,200))) == "\e[38;2;100;150;200m"
@test string(Crayon(foreground = (100,150,200), background = (200,210,220))) == "\e[38;2;100;150;200;48;2;200;210;220m"
@test string(Crayon(foreground = (100,150,200), background = (200,210,220), bold = true)) == "\e[38;2;100;150;200;48;2;200;210;220;1m"

# Mixing color modes
@test string(Crayon(foreground = :red, background = (10,20,30))) == "\e[31;48;2;10;20;30m"
@test string(Crayon(foreground = :60, background = (10,20,30))) == "\e[38;5;60;48;2;10;20;30m"

# CrayonStack
cs = CrayonStack()
@test string(cs) == string(Crayon(foreground = :default, background = :default, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
push!(cs, Crayon(foreground = :red))
@test string(cs) == string(Crayon(foreground = :red, background = :default, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
push!(cs, Crayon(foreground = :green))
@test string(cs) == string(Crayon(foreground = :green, background = :default, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
push!(cs, Crayon(bold = true, background = 125))
@test string(cs) == string(Crayon(foreground = :green, background = 125, bold = true, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
push!(cs, Crayon(bold = false))
@test string(cs) == string(Crayon(foreground = :green, background = 125, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
pop!(cs) # Popping the bold = false
@test string(cs) == string(Crayon(foreground = :green, background = 125, bold = true, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
pop!(cs) # Popping the bold = true + background = 125
@test string(cs) == string(Crayon(foreground = :green, background = :default, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
pop!(cs) # Popping the foreground = :green
@test string(cs) == string(Crayon(foreground = :red, background = :default, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
pop!(cs) # Popping the foreground = :red
@test string(cs) == string(Crayon(foreground = :default, background = :default, bold = false, italics = false, underline = false, strikethrough = false, blink = false, conceal = false, negative = false, faint = false))
@test_throws ArgumentError pop!(cs)

# Incremental mode CrayonStack
cs = CrayonStack(incremental = true) # State:
push!(cs, Crayon(foreground = :red)) # State: fg = red, change: fg = red
@test string(cs) == string(Crayon(foreground = :red))
push!(cs, Crayon(foreground = :red)) # State: fg = red, change:
@test string(cs) == ""
push!(cs, Crayon(foreground = :blue)) # State: fg = blue, change: fg = blue
@test string(cs) == string(Crayon(foreground = :blue))
push!(cs, Crayon(bold = true)) # State fg = blue, bold = true, change: bold = true
@test string(cs) == string(Crayon(bold = true))
pop!(cs) # State fg = blue, change: bold = false
@test string(cs) == string(Crayon(bold = false))
pop!(cs) # State fg = red, change: fg = red
@test string(cs) == string(Crayon(foreground = :red))
pop!(cs) # State fg = red, change:
@test string(cs) == ""
pop!(cs) # State change: fg = default
@test string(cs) == string(Crayon(foreground = :default))

# Merge

@test string(merge()) == ""
@test string(merge(Crayon(foreground = :blue, background = :red))) == string(Crayon(foreground = :blue, background = :red))
@test string(merge(Crayon(foreground = :blue), Crayon(background = :red)))  == string(Crayon(foreground = :blue, background = :red))
@test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true)))  == string(Crayon(foreground = :blue, background = :red, bold = true))
@test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true)))  == string(Crayon(foreground = :blue, background = :red, bold = true))
@test string(merge(Crayon(foreground = :red), Crayon(foreground = :blue))) == string(Crayon(foreground = :blue))
@test string(merge(Crayon(foreground = :red), Crayon(negative = true))) == string(Crayon(foreground = :red, negative = true))

string(BLACK_BG * WHITE_FG * BOLD) == string(Crayon(foreground = :white, background = :black, bold = true))

# print_with_color
io = IOBuffer()
print_with_color(Crayon(foreground = :red), io, "haho")
@test takebuf_string(io) == string(Crayon(foreground = :red), "haho", inv(Crayon(foreground = :red)))

Crayons.test_system_colors(IOBuffer())
Crayons.test_256_colors(IOBuffer())
Crayons.test_24bit_colors(IOBuffer())
end # withenv
