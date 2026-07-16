# [[fg:]<col>] [bg:<col>] ([[!]properties], ...)

macro crayon_str(str::String)
    _reset         = ANSIStyle()
    _bold          = ANSIStyle()
    _faint         = ANSIStyle()
    _italics       = ANSIStyle()
    _underline     = ANSIStyle()
    _blink         = ANSIStyle()
    _negative      = ANSIStyle()
    _conceal       = ANSIStyle()
    _strikethrough = ANSIStyle()

    fgcol = ANSIColor()
    bgcol = ANSIColor()

    for word in split(str)
        token = word
        enabled = true
        parse_state = :style

        if word[1] == '!'
            enabled = false
            token = word[2:end]
            @goto doparse
        end

        if ':' in word
            ws = split(word, ':')
            if length(ws) != 2
                @goto parse_err
            end
            val, token = ws
            if val == "fg"
                parse_state = :fg_color
            elseif val == "bg"
                parse_state = :bg_color
            else
                @goto parse_err
            end
            @goto doparse
            @label parse_err
            throw(ArgumentError("should have the format [fg/bg]:color"))
        end

        @label doparse
        if parse_state == :fg_color || parse_state == :bg_color
            color = _parse_color_string(token)
            if parse_state == :fg_color
                fgcol = color
            else
                bgcol = color
            end
        elseif parse_state == :style
            if token == "reset"
                _reset = ANSIStyle(enabled)
            elseif token == "bold"
                _bold = ANSIStyle(enabled)
            elseif token == "faint"
                _faint = ANSIStyle(enabled)
            elseif token == "italics"
                _italics = ANSIStyle(enabled)
            elseif token == "underline"
                _underline = ANSIStyle(enabled)
            elseif token == "blink"
                _blink = ANSIStyle(enabled)
            elseif token == "negative"
                _negative = ANSIStyle(enabled)
            elseif token == "conceal"
                _conceal = ANSIStyle(enabled)
            elseif token == "strikethrough"
                _strikethrough = ANSIStyle(enabled)
            else
                fgcol = _parse_color_string(token)
            end
        end
    end

    return Crayon(
        fgcol,
        bgcol,
        _reset,
        _bold,
        _faint,
        _italics,
        _underline,
        _blink,
        _negative,
        _conceal,
        _strikethrough,
    )
end

const HEX_COLOR_REGEX = r"^(?:#|0[xX])?([0-9a-fA-F]{6})$"
const RGB_COLOR_REGEX = r"^\(([0-9]+),([0-9]+),([0-9]+)\)$"

function _parse_color_string(token::AbstractString)
    hexmatch = match(HEX_COLOR_REGEX, token)
    if hexmatch !== nothing
        return _parse_color(parse(UInt32, hexmatch.captures[1]; base = 16))
    end

    nint = tryparse(Int, token)
    nint !== nothing && return _parse_color(nint)

    m = match(RGB_COLOR_REGEX, token)
    if m !== nothing
        rgb = ntuple(i -> parse(Int, m.captures[i]), 3)
        return _parse_color(rgb)
    end

    color = Symbol(token)
    haskey(COLORS, color) && return _parse_color(color)

    throw(ArgumentError("could not parse $token as a color"))
end
