function test_system_colors(io::IO = STDOUT)
    for col in keys(COLORS)
        tok =
        print(io, Crayon(foreground = col), lpad("$col", 15, ' '), " ", NormalCrayon())
        print(io, Crayon(background = col), col, NormalCrayon(), "\n")
    end
end

test_256_colors(codes::Bool = true) = test_256_colors(STDOUT, codes)
test_256_colors(io::IO) = test_256_colors(io, true)
function test_256_colors(io::IO, codes::Bool)
    println(io, "System colors (0..15):")

    for c in 0:15
        str = codes ? string(lpad(c, 3, '0'), " ") : "██"
        print(io, Crayon(foreground = c), str, NormalCrayon())
        (c+1) % 8 == 0 && println(io)
    end
    print(io, "\n\n")

    println(io, "Color cube, 6×6×6 (16..231):")
    for c in 16:231
        str = codes ? string(lpad(c, 3, '0'), " ") : "██"
        print(io, Crayon(foreground = c), str, NormalCrayon())
        (c - 16) %  6 ==  5 && println(io)
        (c - 16) % 36 == 35 && println(io)
    end

    println(io, "Grayscale ramp (232..255):")
    for c in 232:255
        str = codes ? string(lpad(c, 3, '0'), " ") : "██"
        print(io, Crayon(foreground = c), str, NormalCrayon())
        (c - 232) %  6 == 5 && println(io)
    end
end

test_24bit_colors(codes::Bool = true) = test_24bit_colors(STDOUT, codes)
test_24bit_colors(io::IO) = test_24bit_colors(io, true)
function test_24bit_colors(io::IO, codes::Bool)
    steps = 0:30:255
    for r in steps
        for g in steps
            for b in steps
                str = codes ? string(lpad(r, 3, '0'), "|", lpad(g, 3, '0'), "|", lpad(b, 3, '0'), " ") : "██"
                print(io, Crayon(; foreground = (r,g,b)), str, NormalCrayon())
            end
        println(io)
        end
    println(io)
    end
end
