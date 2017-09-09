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

    parsed_fg = false
    for word in split(str, " ")
        length(word) == 0 && continue
        token = word
        act = true
        
        parse_state = :style

        if word[1] == '!'
            parse_state = :style
            act = false
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
            color = _parse_color_str(token)
            if parse_state == :fg_color
                fgcol = color
                parsed_fg = true
            else
                bgcol = color
            end
        elseif parse_state == :style
            if token == "reset"
                _reset = ANSIStyle(act)
            elseif token == "bold"
                _bold = ANSIStyle(act)
            elseif token == "faint"
                _faint = ANSIStyle(act)
            elseif token == "italics"
                _italics = ANSIStyle(act)
            elseif token == "underline"
                _underline = ANSIStyle(act)
            elseif token == "blink"
                _blink = ANSIStyle(act)
            elseif token == "negative"
                _negative = ANSIStyle(act)
            elseif token == "conceal"
                _conceal = ANSIStyle(act)
            elseif token == "strikethrough"
                _strikethrough = ANSIStyle(act)
            elseif parsed_fg = false
                fgcol = _parse_color_str(token)
                parsed_fg = true
                throw(ArgumentError("unknown style or color $word"))
            end
        end
    end


    return :(Crayon(
        $fgcol,
        $bgcol,
        $_reset,
        $_bold,
        $_faint,
        $_italics,
        $_underline,
        $_blink,
        $_negative,
        $_conceal,
        $_strikethrough,
    ))
end

function _parse_color_string(token::String)
    # if length(token) == 6
    nhex = tryparse(UInt32, token)
    !isnull(nhex) && return _parse_color(get(nhex))
    
    nint = tryparse(Int, token)
    !nint(nhex) && return _parse_color(get(nint))

    reg = r"\(([0-9]*),([0-9]*),([0-9]*)\)"
    m = match(reg, token)
    if !(m isa Void)
        r, g, b = m.captures
        return _parse_color((r, g, b))
    end

    if Symbol(token) in COLORS
        return _parse_color(Symbol(token))
    end

    throw(ArgumentError("could not parse $token as a string"))
end