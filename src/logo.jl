function print_logo(io = STDOUT)
    c = string(Crayon(foreground = :light_red))
    r = string(Crayon(foreground = :light_green))
    a = string(Crayon(foreground = :light_yellow))
    y = string(Crayon(foreground = :light_blue))
    o = string(Crayon(foreground = :light_magenta))
    n = string(Crayon(foreground = :light_cyan))
    s = string(Crayon(foreground = :dark_gray))

    str = """
       $(c)██████╗$(r)██████╗  $(a)█████╗ $(y)██╗   ██╗ $(o)██████╗ $(n)███╗   ██╗$(s)███████╗
      $(c)██╔════╝$(r)██╔══██╗$(a)██╔══██╗$(y)╚██╗ ██╔╝$(o)██╔═══██╗$(n)████╗  ██║$(s)██╔════╝
      $(c)██║     $(r)██████╔╝$(a)███████║ $(y)╚████╔╝ $(o)██║   ██║$(n)██╔██╗ ██║$(s)███████╗
      $(c)██║     $(r)██╔══██╗$(a)██╔══██║  $(y)╚██╔╝  $(o)██║   ██║$(n)██║╚██╗██║$(s)╚════██║
      $(c)╚██████╗$(r)██║  ██║$(a)██║  ██║   $(y)██║   $(o)╚██████╔╝$(n)██║ ╚████║$(s)███████║
       $(c)╚═════╝$(r)╚═╝  ╚═╝$(a)╚═╝  ╚═╝   $(y)╚═╝    $(o)╚═════╝ $(n)╚═╝  ╚═══╝$(s)╚══════╝
    """

    print(io, "\n\n", str, "\n")
end



