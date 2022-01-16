using Crayons
using Crayons.Box
using Test

withenv("FORCE_COLOR" => true) do

Crayons.print_logo()
Crayons.test_system_colors(IOBuffer())
Crayons.test_24bit_colors(IOBuffer())
Crayons.test_256_colors(IOBuffer())

@testset "styles" begin
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

@testset "mixing color modes" begin
    @test string(Crayon(foreground = :red, background = (10,20,30))) == "\e[31;48;2;10;20;30m"
    @test string(Crayon(foreground = :60, background = (10,20,30))) == "\e[38;5;60;48;2;10;20;30m"
end

@testset "hex colors" begin
    @test string(Crayon(foreground = 0x000000)) ==  string(Crayon(foreground = (0,0,0)))
    @test string(Crayon(foreground = 0xffffff)) ==  string(Crayon(foreground = (255,255,255)))
    @test string(Crayon(foreground = 0xffaadd)) ==  string(Crayon(foreground = (255,170,221)))
end

@testset "string macro" begin
    @test string(crayon"0xffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"ffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"#ffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"fg:0xffffff") == string(Crayon(foreground = 0xffffff))
    @test string(crayon"bg:0xff00ff fg:0xffffff") == string(Crayon(foreground = 0xffffff, background = 0xff00ff))
    @test string(crayon"bg:red bold !underline") == string(Crayon(background = :red, bold = true, underline = false))
    @test string(crayon"bg:(1,2,3) fg:(2,1,5)") == string(Crayon(background = (1,2,3), foreground = (2,1,5)))
end

@testset "force 256 colors" begin
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

@testset "incremental mode CrayonStack" begin
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

@testset "merge" begin
    @test string(merge(Crayon(foreground = :blue, background = :red))) == string(Crayon(foreground = :blue, background = :red))
    @test string(merge(Crayon(foreground = :blue), Crayon(background = :red)))  == string(Crayon(foreground = :blue, background = :red))
    @test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true))) == string(Crayon(foreground = :blue, background = :red, bold = true))
    @test string(merge(Crayon(foreground = :blue), Crayon(background = :red), Crayon(bold = true))) == string(Crayon(foreground = :blue, background = :red, bold = true))
    @test string(merge(Crayon(foreground = :red), Crayon(foreground = :blue))) == string(Crayon(foreground = :blue))
    @test string(merge(Crayon(foreground = :red), Crayon(negative = true))) == string(Crayon(foreground = :red, negative = true))

    string(BLACK_BG * WHITE_FG * BOLD) == string(Crayon(foreground = :white, background = :black, bold = true))
end

@testset "call overloading" begin
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

@testset "8bit - 256 colors" begin
    # en.wikipedia.org/wiki/ANSI_escape_code#8-bit

    # Standard colors (primary colors): 0 - 15
    @test crayon"000000" |> Crayons.to_256_colors == crayon"0"
    @test crayon"800000" |> Crayons.to_256_colors == crayon"1"
    @test crayon"008000" |> Crayons.to_256_colors == crayon"2"
    @test crayon"808000" |> Crayons.to_256_colors == crayon"3"
    @test crayon"000080" |> Crayons.to_256_colors == crayon"4"
    @test crayon"800080" |> Crayons.to_256_colors == crayon"5"
    @test crayon"008080" |> Crayons.to_256_colors == crayon"6"
    @test crayon"c0c0c0" |> Crayons.to_256_colors == crayon"7"
    # High-intensity colors are all duplicates from the cube or gray levels
    @test crayon"808080" |> Crayons.to_256_colors != crayon"8"  # 240
    @test crayon"ff0000" |> Crayons.to_256_colors != crayon"9"  # 196
    @test crayon"00ff00" |> Crayons.to_256_colors != crayon"10"  # 46
    @test crayon"ffff00" |> Crayons.to_256_colors != crayon"11"  # 226
    @test crayon"0000ff" |> Crayons.to_256_colors != crayon"12"  # 21
    @test crayon"ff00ff" |> Crayons.to_256_colors != crayon"13"  # 201
    @test crayon"00ffff" |> Crayons.to_256_colors != crayon"14"  # 51
    @test crayon"ffffff" |> Crayons.to_256_colors != crayon"15"  # 231

    # 6x6x6 cube: 16 - 231
    foregroundCrayon(fgcol) = Crayon(fgcol, Crayons.ANSIColor(), (Crayons.ANSIStyle() for _ in 1:9)...)
    UInt8tohex(s) = string(s, base=16, pad=2)

    levels = [0, 95, 135, 175, 215, 255]
    for (k, lk) in enumerate(levels), (j, lj) in enumerate(levels), (i, li) in enumerate(levels)
        i == 1 && j == 1 && k == 1 && continue  # ansi 16 is a duplicate of ansi 0 (tested in primary colors)
        @test (
            UInt8tohex(lk) * UInt8tohex(lj) * UInt8tohex(li) |>
            Crayons._parse_color_string |> foregroundCrayon |> Crayons.to_256_colors ==
            Crayon(foreground = 16 + (k - 1) * length(levels)^2 + (j - 1) * length(levels) + (i - 1))
        )
    end

    # gray levels: 232 - 255
    @test crayon"080808" |> Crayons.to_256_colors == crayon"232"
    @test crayon"121212" |> Crayons.to_256_colors == crayon"233"
    @test crayon"1c1c1c" |> Crayons.to_256_colors == crayon"234"
    @test crayon"262626" |> Crayons.to_256_colors == crayon"235"
    @test crayon"303030" |> Crayons.to_256_colors == crayon"236"
    @test crayon"3a3a3a" |> Crayons.to_256_colors == crayon"237"
    @test crayon"444444" |> Crayons.to_256_colors == crayon"238"
    @test crayon"4e4e4e" |> Crayons.to_256_colors == crayon"239"
    @test crayon"585858" |> Crayons.to_256_colors == crayon"240"
    @test crayon"626262" |> Crayons.to_256_colors == crayon"241"
    @test crayon"6c6c6c" |> Crayons.to_256_colors == crayon"242"
    @test crayon"767676" |> Crayons.to_256_colors == crayon"243"
    @test crayon"808080" |> Crayons.to_256_colors == crayon"244"
    @test crayon"8a8a8a" |> Crayons.to_256_colors == crayon"245"
    @test crayon"949494" |> Crayons.to_256_colors == crayon"246"
    @test crayon"9e9e9e" |> Crayons.to_256_colors == crayon"247"
    @test crayon"a8a8a8" |> Crayons.to_256_colors == crayon"248"
    @test crayon"b2b2b2" |> Crayons.to_256_colors == crayon"249"
    @test crayon"bcbcbc" |> Crayons.to_256_colors == crayon"250"
    @test crayon"c6c6c6" |> Crayons.to_256_colors == crayon"251"
    @test crayon"d0d0d0" |> Crayons.to_256_colors == crayon"252"
    @test crayon"dadada" |> Crayons.to_256_colors == crayon"253"
    @test crayon"e4e4e4" |> Crayons.to_256_colors == crayon"254"
    @test crayon"eeeeee" |> Crayons.to_256_colors == crayon"255"
end

@testset "8bit ansi approximation" begin
    # codegolf.stackexchange.com/q/156918
    @test Crayons.to_256_colors(crayon"(95,135,0)") == crayon"64"
    @test Crayons.to_256_colors(crayon"(255,255,255)") == crayon"231"
    @test Crayons.to_256_colors(crayon"(238,238,238)") == crayon"255"
    @test Crayons.to_256_colors(crayon"(90,133,140)") == crayon"66"
    @test Crayons.to_256_colors(crayon"(218,215,216)") == crayon"188"
    @test Crayons.to_256_colors(crayon"(175,0,155)") == crayon"127"
    @test Crayons.to_256_colors(crayon"(115,155,235)") == crayon"111"
    @test Crayons.to_256_colors(crayon"(0,175,95)") == crayon"35"

    # misc (UnicodePlots)
    @test Crayons.to_256_colors(crayon"(255,102,255)") == crayon"207"
    @test Crayons.to_256_colors(crayon"(255,135,0)") == crayon"208"
    @test Crayons.to_256_colors(crayon"(187,0,187)") == crayon"127"
    @test Crayons.to_256_colors(crayon"(50,100,50)") == crayon"59"
    @test Crayons.to_256_colors(crayon"(102,102,0)") == crayon"58"
    @test Crayons.to_256_colors(crayon"(200,50,0)") == crayon"166"
    @test Crayons.to_256_colors(crayon"(0,51,102)") == crayon"23"
    @test Crayons.to_256_colors(crayon"(102,51,0)") == crayon"58"
    @test Crayons.to_256_colors(crayon"(0,204,204)") == crayon"44"
end

@testset "named HTML to 8bit" begin
    # www.w3schools.com/colors/colors_hex.asp
    @test crayon"000000" |> Crayons.to_256_colors == crayon"0"
    @test crayon"000080" |> Crayons.to_256_colors == crayon"4"
    @test crayon"00008b" |> Crayons.to_256_colors == crayon"18"
    @test crayon"0000cd" |> Crayons.to_256_colors == crayon"20"
    @test crayon"0000ff" |> Crayons.to_256_colors == crayon"21"
    @test crayon"006400" |> Crayons.to_256_colors == crayon"22"
    @test crayon"008000" |> Crayons.to_256_colors == crayon"2"
    @test crayon"008080" |> Crayons.to_256_colors == crayon"6"
    @test crayon"008b8b" |> Crayons.to_256_colors == crayon"30"
    @test crayon"00bfff" |> Crayons.to_256_colors == crayon"39"
    @test crayon"00ced1" |> Crayons.to_256_colors == crayon"44"
    @test crayon"00fa9a" |> Crayons.to_256_colors == crayon"48"
    @test crayon"00ff00" |> Crayons.to_256_colors == crayon"46"
    @test crayon"00ff7f" |> Crayons.to_256_colors == crayon"48"
    @test crayon"00ffff" |> Crayons.to_256_colors == crayon"51"
    @test crayon"191970" |> Crayons.to_256_colors == crayon"17"
    @test crayon"1e90ff" |> Crayons.to_256_colors == crayon"33"
    @test crayon"20b2aa" |> Crayons.to_256_colors == crayon"37"
    @test crayon"228b22" |> Crayons.to_256_colors == crayon"28"
    @test crayon"2e8b57" |> Crayons.to_256_colors == crayon"29"
    @test crayon"2f4f4f" |> Crayons.to_256_colors == crayon"23"
    @test crayon"32cd32" |> Crayons.to_256_colors == crayon"77"
    @test crayon"3cb371" |> Crayons.to_256_colors == crayon"71"
    @test crayon"40e0d0" |> Crayons.to_256_colors == crayon"80"
    @test crayon"4169e1" |> Crayons.to_256_colors == crayon"62"
    @test crayon"4682b4" |> Crayons.to_256_colors == crayon"67"
    @test crayon"483d8b" |> Crayons.to_256_colors == crayon"60"
    @test crayon"48d1cc" |> Crayons.to_256_colors == crayon"80"
    @test crayon"4b0082" |> Crayons.to_256_colors == crayon"54"
    @test crayon"556b2f" |> Crayons.to_256_colors == crayon"58"
    @test crayon"5f9ea0" |> Crayons.to_256_colors == crayon"73"
    @test crayon"6495ed" |> Crayons.to_256_colors == crayon"69"
    @test crayon"663399" |> Crayons.to_256_colors == crayon"60"
    @test crayon"66cdaa" |> Crayons.to_256_colors == crayon"79"
    @test crayon"696969" |> Crayons.to_256_colors == crayon"59"
    @test crayon"6a5acd" |> Crayons.to_256_colors == crayon"62"
    @test crayon"6b8e23" |> Crayons.to_256_colors == crayon"64"
    @test crayon"708090" |> Crayons.to_256_colors == crayon"66"
    @test crayon"778899" |> Crayons.to_256_colors == crayon"102"
    @test crayon"7b68ee" |> Crayons.to_256_colors == crayon"99"
    @test crayon"7cfc00" |> Crayons.to_256_colors == crayon"118"
    @test crayon"7fff00" |> Crayons.to_256_colors == crayon"118"
    @test crayon"7fffd4" |> Crayons.to_256_colors == crayon"122"
    @test crayon"800000" |> Crayons.to_256_colors == crayon"1"
    @test crayon"800080" |> Crayons.to_256_colors == crayon"5"
    @test crayon"808000" |> Crayons.to_256_colors == crayon"3"
    @test crayon"808080" |> Crayons.to_256_colors == crayon"244"
    @test crayon"87ceeb" |> Crayons.to_256_colors == crayon"117"
    @test crayon"87cefa" |> Crayons.to_256_colors == crayon"117"
    @test crayon"8a2be2" |> Crayons.to_256_colors == crayon"92"
    @test crayon"8b0000" |> Crayons.to_256_colors == crayon"88"
    @test crayon"8b008b" |> Crayons.to_256_colors == crayon"90"
    @test crayon"8b4513" |> Crayons.to_256_colors == crayon"94"
    @test crayon"8fbc8f" |> Crayons.to_256_colors == crayon"108"
    @test crayon"90ee90" |> Crayons.to_256_colors == crayon"120"
    @test crayon"9370db" |> Crayons.to_256_colors == crayon"98"
    @test crayon"9400d3" |> Crayons.to_256_colors == crayon"92"
    @test crayon"98fb98" |> Crayons.to_256_colors == crayon"120"
    @test crayon"9932cc" |> Crayons.to_256_colors == crayon"98"
    @test crayon"9acd32" |> Crayons.to_256_colors == crayon"113"
    @test crayon"a0522d" |> Crayons.to_256_colors == crayon"130"
    @test crayon"a52a2a" |> Crayons.to_256_colors == crayon"124"
    @test crayon"a9a9a9" |> Crayons.to_256_colors == crayon"145"
    @test crayon"add8e6" |> Crayons.to_256_colors == crayon"152"
    @test crayon"adff2f" |> Crayons.to_256_colors == crayon"154"
    @test crayon"afeeee" |> Crayons.to_256_colors == crayon"159"
    @test crayon"b0c4de" |> Crayons.to_256_colors == crayon"152"
    @test crayon"b0e0e6" |> Crayons.to_256_colors == crayon"152"
    @test crayon"b22222" |> Crayons.to_256_colors == crayon"124"
    @test crayon"b8860b" |> Crayons.to_256_colors == crayon"136"
    @test crayon"ba55d3" |> Crayons.to_256_colors == crayon"134"
    @test crayon"bc8f8f" |> Crayons.to_256_colors == crayon"138"
    @test crayon"bdb76b" |> Crayons.to_256_colors == crayon"143"
    @test crayon"c0c0c0" |> Crayons.to_256_colors == crayon"7"
    @test crayon"c71585" |> Crayons.to_256_colors == crayon"162"
    @test crayon"cd5c5c" |> Crayons.to_256_colors == crayon"167"
    @test crayon"cd853f" |> Crayons.to_256_colors == crayon"173"
    @test crayon"d2691e" |> Crayons.to_256_colors == crayon"166"
    @test crayon"d2b48c" |> Crayons.to_256_colors == crayon"180"
    @test crayon"d3d3d3" |> Crayons.to_256_colors == crayon"188"
    @test crayon"d8bfd8" |> Crayons.to_256_colors == crayon"182"
    @test crayon"da70d6" |> Crayons.to_256_colors == crayon"170"
    @test crayon"daa520" |> Crayons.to_256_colors == crayon"178"
    @test crayon"db7093" |> Crayons.to_256_colors == crayon"168"
    @test crayon"dc143c" |> Crayons.to_256_colors == crayon"161"
    @test crayon"dcdcdc" |> Crayons.to_256_colors == crayon"188"
    @test crayon"dda0dd" |> Crayons.to_256_colors == crayon"182"
    @test crayon"deb887" |> Crayons.to_256_colors == crayon"180"
    @test crayon"e0ffff" |> Crayons.to_256_colors == crayon"195"
    @test crayon"e6e6fa" |> Crayons.to_256_colors == crayon"189"
    @test crayon"e9967a" |> Crayons.to_256_colors == crayon"174"
    @test crayon"ee82ee" |> Crayons.to_256_colors == crayon"213"
    @test crayon"eee8aa" |> Crayons.to_256_colors == crayon"223"
    @test crayon"f08080" |> Crayons.to_256_colors == crayon"210"
    @test crayon"f0e68c" |> Crayons.to_256_colors == crayon"222"
    @test crayon"f0f8ff" |> Crayons.to_256_colors == crayon"231"
    @test crayon"f0fff0" |> Crayons.to_256_colors == crayon"231"
    @test crayon"f0ffff" |> Crayons.to_256_colors == crayon"231"
    @test crayon"f4a460" |> Crayons.to_256_colors == crayon"215"
    @test crayon"f5deb3" |> Crayons.to_256_colors == crayon"223"
    @test crayon"f5f5dc" |> Crayons.to_256_colors == crayon"230"
    @test crayon"f5f5f5" |> Crayons.to_256_colors == crayon"231"
    @test crayon"f5fffa" |> Crayons.to_256_colors == crayon"231"
    @test crayon"f8f8ff" |> Crayons.to_256_colors == crayon"231"
    @test crayon"fa8072" |> Crayons.to_256_colors == crayon"209"
    @test crayon"faebd7" |> Crayons.to_256_colors == crayon"230"
    @test crayon"faf0e6" |> Crayons.to_256_colors == crayon"230"
    @test crayon"fafad2" |> Crayons.to_256_colors == crayon"230"
    @test crayon"fdf5e6" |> Crayons.to_256_colors == crayon"230"
    @test crayon"ff0000" |> Crayons.to_256_colors == crayon"196"
    @test crayon"ff00ff" |> Crayons.to_256_colors == crayon"201"
    @test crayon"ff00ff" |> Crayons.to_256_colors == crayon"201"
    @test crayon"ff1493" |> Crayons.to_256_colors == crayon"198"
    @test crayon"ff4500" |> Crayons.to_256_colors == crayon"202"
    @test crayon"ff6347" |> Crayons.to_256_colors == crayon"203"
    @test crayon"ff69b4" |> Crayons.to_256_colors == crayon"205"
    @test crayon"ff7f50" |> Crayons.to_256_colors == crayon"209"
    @test crayon"ff8c00" |> Crayons.to_256_colors == crayon"208"
    @test crayon"ffa07a" |> Crayons.to_256_colors == crayon"216"
    @test crayon"ffa500" |> Crayons.to_256_colors == crayon"214"
    @test crayon"ffb6c1" |> Crayons.to_256_colors == crayon"217"
    @test crayon"ffc0cb" |> Crayons.to_256_colors == crayon"218"
    @test crayon"ffd700" |> Crayons.to_256_colors == crayon"220"
    @test crayon"ffdab9" |> Crayons.to_256_colors == crayon"223"
    @test crayon"ffdead" |> Crayons.to_256_colors == crayon"223"
    @test crayon"ffe4b5" |> Crayons.to_256_colors == crayon"223"
    @test crayon"ffe4c4" |> Crayons.to_256_colors == crayon"224"
    @test crayon"ffe4e1" |> Crayons.to_256_colors == crayon"224"
    @test crayon"ffebcd" |> Crayons.to_256_colors == crayon"230"
    @test crayon"ffefd5" |> Crayons.to_256_colors == crayon"230"
    @test crayon"fff0f5" |> Crayons.to_256_colors == crayon"231"
    @test crayon"fff5ee" |> Crayons.to_256_colors == crayon"231"
    @test crayon"fff8dc" |> Crayons.to_256_colors == crayon"230"
    @test crayon"fffacd" |> Crayons.to_256_colors == crayon"230"
    @test crayon"fffaf0" |> Crayons.to_256_colors == crayon"231"
    @test crayon"fffafa" |> Crayons.to_256_colors == crayon"231"
    @test crayon"ffff00" |> Crayons.to_256_colors == crayon"226"
    @test crayon"ffffe0" |> Crayons.to_256_colors == crayon"230"
    @test crayon"fffff0" |> Crayons.to_256_colors == crayon"231"
    @test crayon"ffffff" |> Crayons.to_256_colors == crayon"231"
end

@testset "4bit" begin
    @test crayon"0000ff" |> Crayons.to_system_colors == Crayon(foreground = :light_blue)
    @test crayon"00ff00" |> Crayons.to_system_colors == Crayon(foreground = :light_green)
    @test crayon"ff0000" |> Crayons.to_system_colors == Crayon(foreground = :light_red)
end

end # withenv
