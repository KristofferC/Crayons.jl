using Crayons
using Base.Test

withenv("FORCE_COLOR" => true) do

# Styles
@test string(Crayon(bold = true)) == "\e[1m"
@test string(Crayon(bold = false)) == "\e[21m"
@test string(Crayon(underline = true)) == "\e[4m"
@test string(Crayon(underline = false)) == "\e[24m"
@test string(Crayon(bold = true, underline = false)) == "\e[1;24m"
@test string(Crayon(italics = false)) == "\e[23m"
@test string(Crayon(italics = true, underline = false)) == "\e[3;24m"

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
@test string(cs) == string(Crayon(foreground = :default, background = :default, bold = false, italics = false, underline = false))
push!(cs, Crayon(foreground = :red))
@test string(cs) == string(Crayon(foreground = :red, background = :default, bold = false, italics = false, underline = false))
push!(cs, Crayon(foreground = :green))
@test string(cs) == string(Crayon(foreground = :green, background = :default, bold = false, italics = false, underline = false))
push!(cs, Crayon(bold = true, background = 125))
@test string(cs) == string(Crayon(foreground = :green, background = 125, bold = true, italics = false, underline = false))
push!(cs, Crayon(bold = false))
@test string(cs) == string(Crayon(foreground = :green, background = 125, bold = false, italics = false, underline = false))
pop!(cs) # Popping the bold = false
@test string(cs) == string(Crayon(foreground = :green, background = 125, bold = true, italics = false, underline = false))
pop!(cs) # Popping the bold = true + background = 125
@test string(cs) == string(Crayon(foreground = :green, background = :default, bold = false, italics = false, underline = false))
pop!(cs) # Popping the foreground = :green
@test string(cs) == string(Crayon(foreground = :red, background = :default, bold = false, italics = false, underline = false))
pop!(cs) # Popping the foreground = :red
@test string(cs) == string(Crayon(foreground = :default, background = :default, bold = false, italics = false, underline = false))

# Merge

@test string(merge()) == ""
@test string(merge(Crayon(foreground = :blue, background = :red))) == string(Crayon(foreground = :blue, background = :red))
@test string(merge(Crayon(foreground = :blue), Crayon(background = :red)))  == string(Crayon(foreground = :blue, background = :red))
@test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true)))  == string(Crayon(foreground = :blue, background = :red, bold = true))
@test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true)))  == string(Crayon(foreground = :blue, background = :red, bold = true))
@test string(merge(Crayon(foreground = :red), Crayon(foreground = :blue))) == string(Crayon(foreground = :blue))

# print_with_color
io = IOBuffer()
print_with_color(Crayon(foreground = :red), io, "haho")
@test takebuf_string(io) == string(Crayon(foreground = :red), "haho", Crayons.NormalCrayon())

Crayons.test_system_colors(IOBuffer())
Crayons.test_256_colors(IOBuffer())
Crayons.test_24bit_colors(IOBuffer())

end # withenv
