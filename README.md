<h1 align="center">
    <img width="400" src="logo.png" alt="crayons">
    <br>
</h1>

> Colored and styled strings for terminals.

[![Build Status](https://travis-ci.org/KristofferC/Crayons.jl.svg?branch=master)](https://travis-ci.org/KristofferC/Crayons.jl) [![codecov](https://codecov.io/gh/KristofferC/Crayons.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/KristofferC/Crayons.jl)

Crayons is a package to make writing strings in different colors and styles to terminals simple. It supports using the 16 system colors, and both the 256 color and 24 bit true color extensions as well as the common text styles implemented in terminals.

## Installation

```jl
Pkg.add("Crayons")
```

## Usage

The process of printing colored and styled text is simple. First create a `Crayon` and print it to the terminal. This will set up the terminal such that following text printed will be according to the properties of the `Crayon`.

A `Crayon` is created with the keyword only constructor:
```jl
Crayon(foreground,
       background,
       reset,
       bold,
       faint,
       italics,
       underline,
       blink,
       negative,
       conceal,
       strikethrough)
```

The `foreground` and `background` argument can be of three types:

* A `symbol` representing a color. The available colors are `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `light_gray`, `default`, `dark_gray`, `light_red`, `light_green`, `light_yellow`, `light_blue`, `light_magenta`, `light_cyan` and `white`. To see the colors in action, try `Crayons.test_system_colors()`. These colors are supported by almost all terminals.
* An integer between 0 and 255. This will use the 256 color ANSI escape codes. To see what number corresponds to what color and if your terminal supports 256 colors, use `Crayons.test_256_colors()`.
* A tuple of three integers all between 0 and 255. This will be interpreted as a `(r,g,b)` 24 bit color. To test your terminal, use `Crayons.test_24bit_colors()`. The support for this is currently quite limited but is being improved in terminals continuously, see [here](https://gist.github.com/XVilka/8346728).
* 
The other keywords all take a `Bool` type and determine if the corresponding style should be explicitly enabled or disabled:

* `reset` - reset all styles and colors to default
* `bold` - bold text, also brighten the colors on some terminals
* `faint` - faint text, not widely supported
* `italics` - italic text, not widely supported
* `underline` - underlined text
* `blink` - blinking text
* `negative` - swap the foreground and background
* `conceal` - hides the text, not widely supported
* `strikethrough` - horizontal line through the middle of the text, not widely supported.

To see text with the different styles active, use `Crayons.test_styles()`

Some examples:

```jl
print(Crayon(foreground = :red), "In red. ", Crayon(bold = true), "Red and bold")
print(Crayon(foreground = 208, background = :red, bold = true), "Orange bold on red")
print(Crayon(negative = true, blink = true, bold = true), "Blinking inverse bold")
print(Crayon(foreground = (100, 100, 255), background = (255, 255, 0)), "Bluish on yellow")
```

For simplicity, `Crayon`s for the foreground / background version of the 16 system colors as well as the different styles are ready-made and can be found in the `Crayons.Box` module. They have the name `<COLOR_NAME>_<BG/FG>` (note the uppercase) for the colors and simply `<STYLE>` for the different styles. Calling `using` on the `Crayons.Box` module will bring all these into global scope:

```jl
using Crayons.Box
print(GREEN_FG, "This is in green")
print(BOLD, GREEN_FG, BLUE_BG, "Bold green on blue")
```

Note: In order for the color sequences to be printed, the Julia REPL needs to have colors activated or alternatively the `ENV` variable `FORCE_COLOR` need to exist.

## Merging `Crayon`s

Two or more `Crayon`s can be merged resulting in a new `Crayon` that has all the properties of the merged ones. This is done with the function `merge(crayons::Crayon...)` or by simply multiplying `Crayon`s using `*`. If two `Crayon`s specify the same property then the property of the last `Crayon` in the argument list is used:

```jl
r_fg = Crayon(foreground = :red)
g_bg = Crayon(background = :green)
merged = merge(r_fg, g_bg)
print(merged, "Red foreground on green background!")
print(r_fg * g_bg * Crayons.Box.BOLD, "Bold Red foreground on green background!")
```


## Nesting colors and styles

In order to nest colors and styles there is the `ColorStack` type. Simply `push!` `Crayon`s onto the stack and `pop!` them off and the stack will keep track of what `Crayon` is active. The stack is used just like a `Crayon`:

```jl
r_fg = Crayon(foreground = :red)
g_bg = Crayon(background = :green)
merged = merge(r_fg, g_bg)
print(merged, "Red foreground on green background!")
bold = Crayon(bold = true)
three_merged = merge(r_fg, g_bg, bold)
print(three_merged, "Bold Red foreground on green background!")
```

A `CrayonStack` can also be created in `incremental` mode with `CrayonStack(incremental = true)`. In that case the `CrayonStack` will only print the changes that are needed to go from the previous text state to the new state which results in less code being printed. However, note that this means that the `CrayonStack` need to be printed to the output buffer for *all* changes that is made to it (i.e. both when `push!` and `pop!` is used). The example below shows a working example where all the changes to the stack is printed and one example which will give wrong result since one change is not printed. Both the examples below work if `incremental = false`.

```jl
# Does work
io = IOBuffer()
stack = CrayonStack(incremental = true)
print(io, push!(stack, Crayon(foreground = :red)))
print(io, push!(stack, Crayon(foreground = :red)))
print(io, stack, "This will be red")
print(takebuf_string(io))

# Does not work
io = IOBuffer()
stack = CrayonStack(incremental = true)
push!(stack, Crayon(foreground = :red)) # <- not printing the stack even though we modify it!
print(io, push!(stack, Crayon(foreground = :red)))
print(io, stack, "This will not be red")
print(takebuf_string(io))
```

The reason why the last example does not work is that the stack notices that there is no state change on the second call to `push!` since we just keep the foreground red and will therefore not print anything. Failing to print the stack after *the first* `push!` means that the terminal state and the stack state is out of sync.

## Misc

The Base function `print_with_color` is extended such that the first argument can also be a `Crayon`.

The function `inv` on a `Crayon` will return a `Crayon` that undos what the first `Crayon` did.
As an example `inv(Crayon(bold = true))` will return a `Crayon` that disables bold.


### Related packages:

https://github.com/Aerlinger/AnsiColor.jl

### Author

Kristoffer Carlsson — [@KristofferC](https://github.com/KristofferC)

