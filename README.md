<h1 align="center">
    <img width="400" src="logo.png" alt="crayons">
    <br>
</h1>

> Colored and styled strings for terminals in Julia.

[![Build Status](https://travis-ci.org/KristofferC/Crayons.jl.svg?branch=master)](https://travis-ci.org/KristofferC/Crayons.jl)

Crayons is a package to simplify writing strings in different colors and styles to terminals. It supports using the 16 system colors, and both the 256 color and 24 bit true color extensions.

## Install

```jl
Pkg.add("Crayons")
```

## Usage

The process of printing colored and styled text is simple. First print a `Crayon` and the following text will be printed according to the properties of that `Crayon`.

A `Crayon` is created with the keyword only constructor:
```jl
Crayon(;foreground, background, bold, italics, underline)
```

The `foreground` and `background` argument can be of three types:

* A `symbol` representing a color. The available colors are `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `light_gray`, `default`, `dark_gray`, `light_red`, `light_green`, `light_yellow`, `light_blue`, `light_magenta`, `light_cyan` and `white`. To see the colors in action, try `Crayons.test_system_colors()`. This is supported by most terminals.
* An integer between 0 and 255. This will To see what number corresponds to what color and if your terminal supports 256 colors, use `Crayons.test_256_colors()`.
* A tuple of three integers all between 0 and 255. This will be interpreted as a `(r,g,b)` color. To test your terminal, use `Crayons.test_24bit_colors()`. The support for this is currently quite limited but is being improved in terminals continuously, see [here](https://gist.github.com/XVilka/8346728).

The `bold`, `italics` and `underline` keyword arguments all take a `Bool` type and determine if the corresponding style should be enabled or disabled.

Some examples:

```jl
print(Crayon(foreground = :red), "In red. ", Crayon(bold = true), "Red and bold")
print(Crayon(foreground = 208, background = :red, bold = true), "Orange bold on red")
print(Crayon(foreground = (100, 100, 255), background = (255, 255, 0)), "Bluish on yellow")
```

There exists also a `NormalCrayon` which resets everything back to the defaults:

```jl
print(Crayon(foreground = :red, bold = true), "Red and bold.", NormalCrayon(), " Normal again.")
```

## Merging `Crayon`s

Two or more `Crayon`s can be merged resulting in a new `Crayon` that has all the properties of the merged ones. If two `Crayon`s specify the same property then the last token in the argument list is used:

```jl
r_fg = Crayon(foreground = :red)
g_bg = Crayon(background = :green)
merged = merge(r_fg, g_bg)
print(merged, "Red foreground on green background!")
```


## Nesting

In order to nest colors and styles there is the `ColorStack` type. Simply `push!` `Crayon`s onto the stack and `pop!` them off and the stack will keep track of what `Crayon` is active. The stack is used just like a `Crayon`:

```jl
stack = CrayonStack()
print(stack, "normal text")
print(push!(stack, Crayon(foreground = :red)), "in red")
print(push!(stack, Crayon(foreground = :blue)), "in blue")
print(pop!(stack), "in red again")
print(pop!(stack), "normal text")
```

### Related packages:

https://github.com/Aerlinger/AnsiColor.jl

### Author

Kristoffer Carlsson — [@KristofferC](https://github.com/KristofferC)

