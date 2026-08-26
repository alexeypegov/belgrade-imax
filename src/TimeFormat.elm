module TimeFormat exposing (belgrade, formatDate, formatTime, formatWeekday, isWeekend)

import Date exposing (Date, weekday)
import Time exposing (Month(..), Posix, Weekday(..), Zone)
import Time.Extra exposing (Interval(..))
import TimeZone


belgrade : Zone
belgrade =
    TimeZone.europe__belgrade ()


formatTime : Posix -> String
formatTime posix =
    let
        pad n =
            String.padLeft 2 '0' (String.fromInt n)
    in
    pad (Time.toHour belgrade posix)
        ++ ":"
        ++ pad (Time.toMinute belgrade posix)


formatDate : Posix -> String
formatDate posix =
    let
        date =
            Date.fromPosix belgrade posix
    in
    String.fromInt (Date.day date)
        ++ ". "
        ++ monthName date


formatWeekday : Posix -> String
formatWeekday posix =
    weekDay (Date.fromPosix belgrade posix)


isWeekend : Posix -> Bool
isWeekend posix =
    case weekday (Date.fromPosix belgrade posix) of
        Sat ->
            True

        Sun ->
            True

        _ ->
            False


monthName : Date -> String
monthName date =
    case Date.month date of
        Jan ->
            "januara"

        Feb ->
            "februara"

        Mar ->
            "marta"

        Apr ->
            "aprila"

        May ->
            "maja"

        Jun ->
            "juna"

        Jul ->
            "jula"

        Aug ->
            "avgusta"

        Sep ->
            "septembra"

        Oct ->
            "oktobra"

        Nov ->
            "novembra"

        Dec ->
            "decembra"


weekDay : Date -> String
weekDay date =
    case Date.weekday date of
        Mon ->
            "Ponedeljak"

        Tue ->
            "Utorak"

        Wed ->
            "Sreda"

        Thu ->
            "Četvrtak"

        Fri ->
            "Petak"

        Sat ->
            "Subota"

        Sun ->
            "Nedelja"
