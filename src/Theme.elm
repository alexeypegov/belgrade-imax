module Theme exposing (Theme, forMode)

import Element exposing (Color, rgb255)


type alias Theme =
    { bg : Color
    , fg : Color
    , red : Color
    , yellow : Color
    , light : Color
    , accent : Color
    }


forMode : Bool -> Theme
forMode isDark =
    if isDark then
        dark

    else
        light


dark : Theme
dark =
    { bg = rgb255 18 18 18
    , fg = rgb255 230 230 230
    , red = rgb255 210 45 45
    , yellow = rgb255 230 126 0
    , light = rgb255 150 150 150
    , accent = rgb255 90 150 255
    }


light : Theme
light =
    { bg = rgb255 255 255 255
    , fg = rgb255 20 20 20
    , red = rgb255 210 45 45
    , yellow = rgb255 230 126 0
    , light = rgb255 110 110 110
    , accent = rgb255 40 100 220
    }
