module Theme exposing (Theme, forMode)

import Element exposing (Color, rgb255)


type alias Theme =
    { bg : Color
    , fg : Color
    , red : Color
    , yellow : Color
    , green : Color
    , light : Color
    , separator : Color
    , weekendBg : Color
    , weekdayBg : Color
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
    { bg = rgb255 24 24 24
    , fg = rgb255 210 210 210
    , red = rgb255 210 45 45
    , yellow = rgb255 230 126 0
    , green = rgb255 30 200 30
    , light = rgb255 130 130 130
    , separator = rgb255 60 60 60
    , weekendBg = rgb255 70 30 30
    , weekdayBg = rgb255 40 40 40
    , accent = rgb255 90 150 255
    }


light : Theme
light =
    { bg = rgb255 255 255 255
    , fg = rgb255 20 20 20
    , red = rgb255 210 45 45
    , yellow = rgb255 230 126 0
    , green = rgb255 100 180 100
    , light = rgb255 140 140 140
    , separator = rgb255 240 240 240
    , weekendBg = rgb255 255 220 220
    , weekdayBg = rgb255 240 240 240
    , accent = rgb255 40 100 220
    }
