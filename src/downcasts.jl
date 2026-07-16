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
    r, g, b = color.r, color.g, color.b

    for i in 0:7
        (r, g, b) == SYSTEM_COLOR_RGB[i + 1] && return ANSIColor(UInt8(i), COLORS_256, color.active)
    end

    r6, g6, b6 = _cube_level(r), _cube_level(g), _cube_level(b)
    cube = 16 + 36r6 + 6g6 + b6
    cube_rgb = (COLOR_CUBE_LEVELS[r6 + 1], COLOR_CUBE_LEVELS[g6 + 1], COLOR_CUBE_LEVELS[b6 + 1])

    gray_level = clamp(round(Int, (Int(r) + Int(g) + Int(b) - 24) / 30), 0, 23)
    gray = 8 + 10gray_level
    ansi = if _color_distance((r, g, b), (gray, gray, gray)) < _color_distance((r, g, b), cube_rgb)
        232 + gray_level
    else
        cube
    end
    return ANSIColor(UInt8(ansi), COLORS_256, color.active)
end

# 24bit -> 16 system colors
function to_system_colors(crayon::Crayon)
    fg = crayon.fg
    bg = crayon.bg
    crayon.fg.style in (COLORS_24BIT, COLORS_256) && (fg = to_system_colors(crayon.fg))
    crayon.bg.style in (COLORS_24BIT, COLORS_256) && (bg = to_system_colors(crayon.bg))
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

const COLOR_CUBE_LEVELS = (0, 95, 135, 175, 215, 255)
const SYSTEM_COLOR_RGB = (
    (0x00, 0x00, 0x00), (0x80, 0x00, 0x00), (0x00, 0x80, 0x00), (0x80, 0x80, 0x00),
    (0x00, 0x00, 0x80), (0x80, 0x00, 0x80), (0x00, 0x80, 0x80), (0xc0, 0xc0, 0xc0),
    (0x80, 0x80, 0x80), (0xff, 0x00, 0x00), (0x00, 0xff, 0x00), (0xff, 0xff, 0x00),
    (0x00, 0x00, 0xff), (0xff, 0x00, 0xff), (0x00, 0xff, 0xff), (0xff, 0xff, 0xff),
)

_cube_level(c) = c < 48 ? 0 : c < 115 ? 1 : min((Int(c) - 35) ÷ 40, 5)

function _color_distance(a, b)
    sum((Int(a[i]) - Int(b[i]))^2 for i in 1:3)
end

function _ansi256_rgb(value::UInt8)
    index = Int(value)
    index < 16 && return SYSTEM_COLOR_RGB[index + 1]
    if index < 232
        index -= 16
        return (COLOR_CUBE_LEVELS[index ÷ 36 + 1],
                COLOR_CUBE_LEVELS[index % 36 ÷ 6 + 1],
                COLOR_CUBE_LEVELS[index % 6 + 1])
    end
    gray = 8 + 10(index - 232)
    return (gray, gray, gray)
end

function to_system_colors(color::ANSIColor)
    @assert color.style in (COLORS_24BIT, COLORS_256)
    rgb = color.style == COLORS_24BIT ? (color.r, color.g, color.b) : _ansi256_rgb(color.r)
    ansi = 0
    distance = typemax(Int)
    for (i, candidate) in enumerate(SYSTEM_COLOR_RGB)
        candidate_distance = _color_distance(rgb, candidate)
        if candidate_distance < distance
            ansi = i <= 8 ? i - 1 : i + 51
            distance = candidate_distance
        end
    end
    return ANSIColor(UInt8(ansi), COLORS_16, color.active)
end
