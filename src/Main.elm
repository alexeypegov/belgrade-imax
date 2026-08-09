module Main exposing (main)

import Browser
import Browser.Events
import Decoders exposing (scheduleDecoder, sessionDetailsWrapperDecoder)
import Dict
import Element exposing (..)
import Http exposing (Error(..))
import Ports exposing (logError, themeChanged)
import Theme exposing (forMode)
import Types exposing (DaySchedule, Model, ScheduleState(..), Session, SessionDetailsState(..), SessionDetailsWrapper)
import Ui exposing (view)


type alias Flags =
    { darkMode : Bool
    , width : Int
    }


type Msg
    = GotSchedule (Result Http.Error (List DaySchedule))
    | GotSessionDetails String (Result Http.Error SessionDetailsWrapper)
    | ThemeChanged Bool
    | WindowResized Int


cineplexGalerija : String
cineplexGalerija =
    "1119"


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- sampleSchedule : Cmd Msg
-- sampleSchedule =
--     Decode.decodeString scheduleDecoder SampleData.json
--         |> Result.mapError (Decode.errorToString >> Http.BadBody)
--         |> Task.succeed
--         |> Task.perform GotSchedule


fetchSchedule : Cmd Msg
fetchSchedule =
    Http.get
        { url = "https://app.cineplexx.rs/api/v1/cinemas/" ++ cineplexGalerija ++ "/sessions"
        , expect = Http.expectJson GotSchedule scheduleDecoder
        }


formatHttpError : String -> Http.Error -> String
formatHttpError prefix err =
    let
        errorMsg =
            case err of
                BadUrl url ->
                    "bad url: " ++ url

                Timeout ->
                    "timeout"

                NetworkError ->
                    "network error"

                BadStatus status ->
                    "bad status: " ++ String.fromInt status

                BadBody msg ->
                    "bad body: " ++ msg
    in
    prefix ++ ", " ++ errorMsg


fetchSessionDetail : String -> Cmd Msg
fetchSessionDetail id =
    Http.get
        { url = "https://app.cineplexx.rs/api/v1/sessions/" ++ id
        , expect = Http.expectJson (GotSessionDetails id) sessionDetailsWrapperDecoder
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { context =
            { theme = forMode flags.darkMode
            , screenWidth = flags.width
            }
      , schedule = Loading
      , sessionDetails = Dict.empty
      }
    , fetchSchedule
    )


filterImax : List Session -> List Session
filterImax sessions =
    let
        isImax l =
            List.member "IMAX" l.technologies
    in
    List.filter isImax sessions


processSchedule : List DaySchedule -> Model -> ( Model, Cmd Msg )
processSchedule schedule model =
    let
        filtered =
            schedule
                |> List.map (\s -> { s | sessions = filterImax s.sessions })
                |> List.filter (\s -> not (List.isEmpty s.sessions))

        cb : DaySchedule -> List String -> List String
        cb day r =
            List.map .id day.sessions
                |> List.append r

        sessionIds =
            List.foldl cb [] filtered
    in
    ( { model | schedule = Success filtered }
    , sessionIds |> List.reverse |> List.map fetchSessionDetail |> Cmd.batch
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ context } as model) =
    case msg of
        GotSchedule result ->
            case result of
                Ok schedule ->
                    processSchedule schedule model

                Err error ->
                    ( { model | schedule = Failure }, logError (formatHttpError "Unable to fetch schedule" error) )

        GotSessionDetails id result ->
            case result of
                Ok details ->
                    ( { model | sessionDetails = Dict.insert id (SessionDetailsSuccess details) model.sessionDetails }, Cmd.none )

                Err error ->
                    ( { model | sessionDetails = Dict.insert id SessionDetailsFailure model.sessionDetails }, logError (formatHttpError ("Error getting session details " ++ id) error) )

        ThemeChanged isDark ->
            ( { model | context = { context | theme = forMode isDark } }, Cmd.none )

        WindowResized width ->
            ( { model | context = { context | screenWidth = width } }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ themeChanged ThemeChanged
        , Browser.Events.onResize (\w _ -> WindowResized w)
        ]
