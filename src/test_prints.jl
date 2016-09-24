function test(io::IO = STDOUT)
    for (xg, str) in ((:foreground, "Foreground"), (:background, "Background"))
        for col in keys(COLORS)
            tok = Crayon(;(xg, col))
            print(io, tok, "$str color: $col, ANSI code: ")
            show(io, tok)
            println(io, ResetCrayon())
        end
    end
end

function test_256(io::IO = STDOUT)
    for c in 0:16
        print(io, Crayon(foreground = c), lpad(c, 3, '0'), ResetCrayon(), " ")
        c % 8 == 0 && println(io)
    end
    println(io)

    print(io, "    ")
    for c in 17:231
        print(io, Crayon(foreground = c), lpad(c, 3, '0'), ResetCrayon(), " ")
        (c - 16) %  6 ==  5 && println(io)
        (c - 16) % 36 == 35 && println(io)
    end

    for c in 232:255
        print(io, Crayon(foreground = c), lpad(c, 3, '0'), ResetCrayon(), " ")
        (c - 232) %  6 == 5 && println(io)
    end
end

function test_24bit(io::IO = STDOUT)
    steps = 0:30:255
    for xg in (:foreground, :background)
        for r in steps
            for g in steps
                for b in steps
                    print(io, Crayon(;(xg, (r,g,b))), lpad(string(r), 3, '0'), "|", 
                                                      lpad(string(g), 3, '0'), "|", 
                                                      lpad(string(b), 3, '0'), ResetCrayon(), " ")
                end
            println(io)
            end
        println(io)
        end
    println(io)
    end
end
