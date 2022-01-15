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

const _cube_levels = UInt8[0, 95, 135, 175, 215, 255]
const _cube_memoize = Dict{NTuple{3,UInt8},UInt8}()

function rgb2cube(r::UInt8, g::UInt8, b::UInt8)
  min_dist::Int16 = typemax(Int16)
  min_n::UInt8 = typemax(UInt8)
  @inbounds for n ∈ UnitRange{UInt8}(0:215)
    𝓇::Int16 = _cube_levels[n÷UInt8(36)+UInt8(1)]
    ℊ::Int16 = _cube_levels[(n%UInt8(36))÷UInt8(6)+UInt8(1)]
    𝒷::Int16 = _cube_levels[n%UInt8(6)+UInt8(1)]
    if (dist = abs(𝓇 - r) + abs(ℊ - g) + abs(𝒷 - b)) <= min_dist
      min_dist, min_n = dist, n
    end
  end
  return UInt8(16) + min_n
end

@inline primary(c::UInt8) = (c & 0x1) == 0 && (c > 0 ? c == 128 || c == 192 : true)

function to_256_colors(color::ANSIColor)
    @assert color.style == COLORS_24BIT
    r, g, b = color.r, color.g, color.b
    if r == g == b && r % 10 == 8  # gray levels
        ansi = 232 + min((r - 8) ÷ 10, 23)
    elseif primary(r) && primary(g) && primary(b)  # primary colors
        ansi = (r >> 7) + 2(g >> 7) + 4(b >> 7)
    else  # cube 6x6x6
        ansi = get!(_cube_memoize, (r, g, b)) do
            rgb2cube(r, g, b)
        end
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
