using Crayons
using Crayons.Box
using Test

withenv("FORCE_COLOR" => true) do

Crayons.print_logo()

@testset "Styles" begin
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
end

@testset "16 colors" begin
    @test string(Crayon(foreground = :red)) == "\e[31m"
    @test string(Crayon(background = :green)) == "\e[42m"
    @test string(Crayon(foreground = :red, background = :green)) == "\e[31;42m"
    @test string(Crayon(foreground = :red, bold = true)) == "\e[31;1m"
    @test string(Crayon(foreground = :default, background = :default)) == "\e[39;49m"
end

@testset "256 colors" begin
    @test string(Crayon(foreground = 32)) == "\e[38;5;32m"
    @test string(Crayon(foreground = 32, bold = true)) == "\e[38;5;32;1m"
    @test string(Crayon(foreground = 32, background = 15, bold = true)) == "\e[38;5;32;48;5;15;1m"
end

@testset "24 bit colors" begin
    @test string(Crayon(foreground = (100,150,200))) == "\e[38;2;100;150;200m"
    @test string(Crayon(foreground = (100,150,200), background = (200,210,220))) == "\e[38;2;100;150;200;48;2;200;210;220m"
    @test string(Crayon(foreground = (100,150,200), background = (200,210,220), bold = true)) == "\e[38;2;100;150;200;48;2;200;210;220;1m"
end

@testset "Mixing color modes" begin
    @test string(Crayon(foreground = :red, background = (10,20,30))) == "\e[31;48;2;10;20;30m"
    @test string(Crayon(foreground = :60, background = (10,20,30))) == "\e[38;5;60;48;2;10;20;30m"
end

@testset "Hex colors" begin
    @test string(Crayon(foreground = 0x000000)) ==  string(Crayon(foreground = (0,0,0)))
    @test string(Crayon(foreground = 0xffffff)) ==  string(Crayon(foreground = (255,255,255)))
    @test string(Crayon(foreground = 0xffaadd)) ==  string(Crayon(foreground = (255,170,221)))
end

@testset "String macro" begin
    @test string(crayon"0xffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"ffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"#ffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"fg:0xffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"bg:0xff00ff fg:0xffffff") == string(Crayon(foreground = 0xffffff, background = 0xff00ff))
    @test string(crayon"bg:red bold !underline") == string(Crayon(background = :red, bold = true, underline = false))
    @test string(crayon"bg:(1,2,3) fg:(2,1,5)") == string(Crayon(background = (1,2,3), foreground = (2,1,5)))
end

@testset "Force 256 colors" begin
    withenv("FORCE_256_COLORS" => true) do
        @test string(crayon"(0,0,255)") == string(Crayon(foreground = 21))
        @test string(crayon"fg:(0,0,255) bg:(255,0,255)") == string(Crayon(foreground = 21, background = 201))
    end
end

@testset "CrayonStack" begin
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
end

@testset "Incremental mode CrayonStack" begin
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
end

@testset "Merge" begin
    @test string(merge(Crayon(foreground = :blue, background = :red))) == string(Crayon(foreground = :blue, background = :red))
    @test string(merge(Crayon(foreground = :blue), Crayon(background = :red)))  == string(Crayon(foreground = :blue, background = :red))
    @test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true))) == string(Crayon(foreground = :blue, background = :red, bold = true))
    @test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true))) == string(Crayon(foreground = :blue, background = :red, bold = true))
    @test string(merge(Crayon(foreground = :red), Crayon(foreground = :blue))) == string(Crayon(foreground = :blue))
    @test string(merge(Crayon(foreground = :red), Crayon(negative = true))) == string(Crayon(foreground = :red, negative = true))

    string(BLACK_BG * WHITE_FG * BOLD) == string(Crayon(foreground = :white, background = :black, bold = true))
end

@testset "Call overloading" begin
    @test string(Crayon()("hello")) == "hello"
    @test string(Crayon()(split("hello world")[1])) == "hello" # test substrings
    @test string(Crayon(bold=true)("hello")) == string(BOLD, "hello", inv(BOLD))
    @test string(Crayon(bold=true, foreground = :red)("hello")) == string(Crayon(foreground=:red, bold=true), "hello", Crayon(foreground=:default, bold=false))

    @test string("normal", BOLD("bold", RED_FG("red bold", UNDERLINE("red_underline"), "red bold"), "bold"), "normal" ) ==
        string("normal", BOLD, "bold", RED_FG, "red bold", UNDERLINE, "red_underline", inv(UNDERLINE), "red bold", inv(RED_FG), "bold", inv(BOLD), "normal")

    @test string("normal", BOLD*UNDERLINE("bold_underline", ITALICS*RED_FG("everything"), "bold_underline"), "normal") ==
        string("normal", Crayon(bold=true, underline=true),"bold_underline", Crayon(italics=true, foreground=:red), "everything", Crayon(italics=false, foreground=:default),
         "bold_underline", Crayon(bold=false, underline=false), "normal")
end

@testset "Test colors" begin
    Crayons.test_system_colors(IOBuffer())
    Crayons.test_256_colors(IOBuffer())
    Crayons.test_24bit_colors(IOBuffer())
end

@testset "8bit - 256 colors" begin
    # see https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit

    # primary colors: 0 - 15
    @test Crayons.to_256_colors(crayon"000000") == Crayon(foreground = 0)
    @test Crayons.to_256_colors(crayon"800000") == Crayon(foreground = 1)
    @test Crayons.to_256_colors(crayon"008000") == Crayon(foreground = 2)
    @test Crayons.to_256_colors(crayon"808000") == Crayon(foreground = 3)
    @test Crayons.to_256_colors(crayon"000080") == Crayon(foreground = 4)
    @test Crayons.to_256_colors(crayon"800080") == Crayon(foreground = 5)
    @test Crayons.to_256_colors(crayon"008080") == Crayon(foreground = 6)
    @test Crayons.to_256_colors(crayon"c0c0c0") == Crayon(foreground = 7)
    # High-intensity colors are all duplicates from the cube or gray levels
    @test Crayons.to_256_colors(crayon"808080") != Crayon(foreground = 8)  # 240
    @test Crayons.to_256_colors(crayon"ff0000") != Crayon(foreground = 9)  # 196
    @test Crayons.to_256_colors(crayon"00ff00") != Crayon(foreground = 10)  # 46
    @test Crayons.to_256_colors(crayon"ffff00") != Crayon(foreground = 11)  # 226
    @test Crayons.to_256_colors(crayon"0000ff") != Crayon(foreground = 12)  # 21
    @test Crayons.to_256_colors(crayon"ff00ff") != Crayon(foreground = 13)  # 201
    @test Crayons.to_256_colors(crayon"00ffff") != Crayon(foreground = 14)  # 51
    @test Crayons.to_256_colors(crayon"ffffff") != Crayon(foreground = 15)  # 231

    # 6x6x6 cube: 16 - 231
    foregroundCrayon(fgcol) = Crayon(fgcol, Crayons.ANSIColor(), (Crayons.ANSIStyle() for _ in 1:9)...)
    UInt8tohex(s) = string(s, base=16, pad=2)

    levels = Crayons._cube_levels
    for (k, lk) in enumerate(levels), (j, lj) in enumerate(levels), (i, li) in enumerate(levels)
        i == 1 && j == 1 && k == 1 && continue  # ansi 16 is the duplicate of ansi 0 (tested in primary colors)
        @test (
            UInt8tohex(lk) * UInt8tohex(lj) * UInt8tohex(li) |>
            Crayons._parse_color_string |> foregroundCrayon |> Crayons.to_256_colors ==
            Crayon(foreground = 16 + (k - 1) * length(levels)^2 + (j - 1) * length(levels) + (i - 1))
        )
    end

    # gray levels: 232 - 255
    @test Crayons.to_256_colors(crayon"080808") == Crayon(foreground = 232)
    @test Crayons.to_256_colors(crayon"121212") == Crayon(foreground = 233)
    @test Crayons.to_256_colors(crayon"1c1c1c") == Crayon(foreground = 234)
    @test Crayons.to_256_colors(crayon"262626") == Crayon(foreground = 235)
    @test Crayons.to_256_colors(crayon"303030") == Crayon(foreground = 236)
    @test Crayons.to_256_colors(crayon"3a3a3a") == Crayon(foreground = 237)
    @test Crayons.to_256_colors(crayon"444444") == Crayon(foreground = 238)
    @test Crayons.to_256_colors(crayon"4e4e4e") == Crayon(foreground = 239)
    @test Crayons.to_256_colors(crayon"585858") == Crayon(foreground = 240)
    @test Crayons.to_256_colors(crayon"626262") == Crayon(foreground = 241)
    @test Crayons.to_256_colors(crayon"6c6c6c") == Crayon(foreground = 242)
    @test Crayons.to_256_colors(crayon"767676") == Crayon(foreground = 243)
    @test Crayons.to_256_colors(crayon"808080") == Crayon(foreground = 244)
    @test Crayons.to_256_colors(crayon"8a8a8a") == Crayon(foreground = 245)
    @test Crayons.to_256_colors(crayon"949494") == Crayon(foreground = 246)
    @test Crayons.to_256_colors(crayon"9e9e9e") == Crayon(foreground = 247)
    @test Crayons.to_256_colors(crayon"a8a8a8") == Crayon(foreground = 248)
    @test Crayons.to_256_colors(crayon"b2b2b2") == Crayon(foreground = 249)
    @test Crayons.to_256_colors(crayon"bcbcbc") == Crayon(foreground = 250)
    @test Crayons.to_256_colors(crayon"c6c6c6") == Crayon(foreground = 251)
    @test Crayons.to_256_colors(crayon"d0d0d0") == Crayon(foreground = 252)
    @test Crayons.to_256_colors(crayon"dadada") == Crayon(foreground = 253)
    @test Crayons.to_256_colors(crayon"e4e4e4") == Crayon(foreground = 254)
    @test Crayons.to_256_colors(crayon"eeeeee") == Crayon(foreground = 255)
end

@testset "4bit" begin
    @test Crayons.to_system_colors(crayon"0000ff") == Crayon(foreground = :light_blue)
    @test Crayons.to_system_colors(crayon"00ff00") == Crayon(foreground = :light_green)
    @test Crayons.to_system_colors(crayon"ff0000") == Crayon(foreground = :light_red)
end

end # withenv
