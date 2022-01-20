function to_256_colors(crayon::Crayon)
    fg = crayon.fg
    bg = crayon.bg
    crayon.fg.style == COLORS_24BIT && (fg = to_256_colors(crayon.fg))
    crayon.bg.style == COLORS_24BIT && (bg = to_256_colors(crayon.bg))
    return Crayon(
        fg,
        bg,
        crayon.reset,
        crayon.bold,
        crayon.faint,
        crayon.italics,
        crayon.underline,
        crayon.blink,
        crayon.negative,
        crayon.conceal,
        crayon.strikethrough,
    )
end

function to_256_colors(color::ANSIColor)
    @assert color.style == COLORS_24BIT
    r, g, b = rgb = color.r, color.g, color.b
    ansi = if r == g == b && r % 10 == 8
        232 + min((r - 8) ÷ 10, 23)  # gray level
    elseif all(map(c -> (c & 0x1) == 0 && (c > 0 ? c == 128 || c == 192 : true), rgb))
        (r >> 7) + 2(g >> 7) + 4(b >> 7)  # primary color
    else
        r6, g6, b6 = map(c -> c < 48 ? 0 : (c < 114 ? 1 : trunc(Int, (c - 35) / 40)), rgb)
        16 + 36r6 + 6g6 + b6  # cube 6x6x6
    end
    return ANSIColor(UInt8(ansi), COLORS_256, color.active)
end

# 24bit -> 16 system colors
function to_system_colors(crayon::Crayon)
    fg = crayon.fg
    bg = crayon.bg
    crayon.fg.style == COLORS_24BIT && (fg = to_system_colors(crayon.fg))
    crayon.bg.style == COLORS_24BIT && (bg = to_system_colors(crayon.bg))
    return Crayon(
        fg,
        bg,
        crayon.reset,
        crayon.bold,
        crayon.faint,
        crayon.italics,
        crayon.underline,
        crayon.blink,
        crayon.negative,
        crayon.conceal,
        crayon.strikethrough,
    )
end

function compute_value(r, g, b)
    r′, g′, b′ = (r, g, b) ./ 255
    Cmax = max(r′, g′, b′)
    return 100Cmax
    #=
    # This is not needed
    Cmin = min(r′, g′, b′)
    Δ = Cmax - Cmin
    H = begin
        if Cmax == r′
            60 * (((g′ - b′) / Δ) % 6)
        elseif Cmax == g′
            60 * ((b′ - r′) / Δ + 2)
        else
            60 * ((r′ - g′) / Δ + 4)
        end
    end

    S = Cmax == 0 ? 0 : (Δ / Cmax)
    V = Cmax
    return H * 360, S * 100, V * 100
    =#
end

function to_system_colors(color::ANSIColor)
    @assert color.style == COLORS_24BIT
    r, g, b = color.r, color.g, color.b
    value = compute_value(r, g, b)
    
    value = round(Int, value / 50)
    
    if (value == 0)
        ansi = 0
    else
        ansi = (
            (round(Int, b / 255) << 2) |
            (round(Int, g / 255) << 1) |
             round(Int, r / 255)
        )
        value == 2 && (ansi += 60)
    end
    return ANSIColor(UInt8(ansi), COLORS_16, color.active)
end
