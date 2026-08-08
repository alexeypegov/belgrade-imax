port module Ports exposing (logError, themeChanged)


port themeChanged : (Bool -> msg) -> Sub msg


port logError : String -> Cmd msg
