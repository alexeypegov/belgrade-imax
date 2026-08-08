module Decoders exposing (filmDecoder, scheduleDecoder, sessionDetailsDecoder, sessionDetailsWrapperDecoder)

import Iso8601
import Json.Decode as Decode exposing (Decoder, field, int, list, map, map2, map6, string)
import List exposing (concat)
import Types exposing (DaySchedule, Film, Session, SessionDetails, SessionDetailsWrapper, SessionStatus(..))


techDecoder : Decoder (List String)
techDecoder =
    list (list string)
        |> map concat


sessionDecoder : Decoder Session
sessionDecoder =
    map2 Session
        (field "id" string)
        (field "technologies" techDecoder)


dayScheduleDecoder : Decoder DaySchedule
dayScheduleDecoder =
    map2 DaySchedule
        (field "date" Iso8601.decoder)
        (field "sessions" (list sessionDecoder))


scheduleDecoder : Decoder (List DaySchedule)
scheduleDecoder =
    list dayScheduleDecoder


filmDecoder : Decoder Film
filmDecoder =
    map2 Film
        (field "title" string)
        (field "duration" string)


sessionDetailsWrapperDecoder : Decoder SessionDetailsWrapper
sessionDetailsWrapperDecoder =
    map2 SessionDetailsWrapper
        (field "session" sessionDetailsDecoder)
        (field "scheduledFilm" filmDecoder)


statusDecoder : Decoder SessionStatus
statusDecoder =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "green" ->
                        Decode.succeed StatusGreen

                    "yellow" ->
                        Decode.succeed StatusYellow

                    "red" ->
                        Decode.succeed StatusRed

                    unknown ->
                        Decode.succeed (StatusUnknown unknown)
            )


sessionDetailsDecoder : Decoder SessionDetails
sessionDetailsDecoder =
    map6 SessionDetails
        (field "id" string)
        (field "sessionId" string)
        (field "showtime" Iso8601.decoder)
        (field "status" statusDecoder)
        (field "seatsAvailable" int)
        (field "seatsTotal" int)
