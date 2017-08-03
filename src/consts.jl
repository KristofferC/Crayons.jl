module Box

using Crayons

export BLACK_FG,
RED_FG,
GREEN_FG,
YELLOW_FG,
BLUE_FG,
MAGENTA_FG,
CYAN_FG,
LIGHT_GRAY_FG,
DEFAULT_FG,
DARK_GRAY_FG,
LIGHT_RED_FG,
LIGHT_GREEN_FG,
LIGHT_YELLOW_FG,
LIGHT_BLUE_FG,
LIGHT_MAGENTA_FG,
LIGHT_CYAN_FG,
WHITE_FG,
BLACK_BG,
RED_BG,
GREEN_BG,
YELLOW_BG,
BLUE_BG,
MAGENTA_BG,
CYAN_BG,
LIGHT_GRAY_BG,
DEFAULT_BG,
DARK_GRAY_BG,
LIGHT_RED_BG,
LIGHT_GREEN_BG,
LIGHT_YELLOW_BG,
LIGHT_BLUE_BG,
LIGHT_MAGENTA_BG,
LIGHT_CYAN_BG,
WHITE_BG,
BOLD,
FAINT,
ITALICS,
UNDERLINE,
BLINK,
NEGATIVE,
CONCEAL,
STRIKETHROUGH

BLACK_FG         = Crayon(foreground = :black         )
RED_FG           = Crayon(foreground = :red           )
GREEN_FG         = Crayon(foreground = :green         )
YELLOW_FG        = Crayon(foreground = :yellow        )
BLUE_FG          = Crayon(foreground = :blue          )
MAGENTA_FG       = Crayon(foreground = :magenta       )
CYAN_FG          = Crayon(foreground = :cyan          )
LIGHT_GRAY_FG    = Crayon(foreground = :light_gray    )
DEFAULT_FG       = Crayon(foreground = :default       )
DARK_GRAY_FG     = Crayon(foreground = :dark_gray     )
LIGHT_RED_FG     = Crayon(foreground = :light_red     )
LIGHT_GREEN_FG   = Crayon(foreground = :light_green   )
LIGHT_YELLOW_FG  = Crayon(foreground = :light_yellow  )
LIGHT_BLUE_FG    = Crayon(foreground = :light_blue    )
LIGHT_MAGENTA_FG = Crayon(foreground = :light_magenta )
LIGHT_CYAN_FG    = Crayon(foreground = :light_cyan    )
WHITE_FG         = Crayon(foreground = :white         )

BLACK_BG         = Crayon(background = :black         )
RED_BG           = Crayon(background = :red           )
GREEN_BG         = Crayon(background = :green         )
YELLOW_BG        = Crayon(background = :yellow        )
BLUE_BG          = Crayon(background = :blue          )
MAGENTA_BG       = Crayon(background = :magenta       )
CYAN_BG          = Crayon(background = :cyan          )
LIGHT_GRAY_BG    = Crayon(background = :light_gray    )
DEFAULT_BG       = Crayon(background = :default       )
DARK_GRAY_BG     = Crayon(background = :dark_gray     )
LIGHT_RED_BG     = Crayon(background = :light_red     )
LIGHT_GREEN_BG   = Crayon(background = :light_green   )
LIGHT_YELLOW_BG  = Crayon(background = :light_yellow  )
LIGHT_BLUE_BG    = Crayon(background = :light_blue    )
LIGHT_MAGENTA_BG = Crayon(background = :light_magenta )
LIGHT_CYAN_BG    = Crayon(background = :light_cyan    )
WHITE_BG         = Crayon(background = :white         )

BOLD          = Crayon(bold = true)
FAINT         = Crayon(faint = true)
ITALICS       = Crayon(italics = true)
UNDERLINE     = Crayon(underline = true)
BLINK         = Crayon(blink = true)
NEGATIVE      = Crayon(negative = true)
CONCEAL       = Crayon(conceal = true)
STRIKETHROUGH = Crayon(strikethrough = true)

end
