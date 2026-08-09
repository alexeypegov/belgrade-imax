module Ui exposing (..)

import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html, details)
import Html.Attributes
import Theme exposing (Theme)
import Time exposing (Posix)
import TimeFormat exposing (formatDate, formatTime, formatWeekday)
import Types exposing (Context, DaySchedule, Model, ScheduleState(..), SessionDetails, SessionDetailsState(..), SessionStatus(..))


title : Element msg
title =
    el [ centerX, paddingXY 0 32 ] <|
        paragraph [ Font.size 32, Font.bold ]
            [ text "Raspored IMAX projekcija u Beogradu" ]


dayTitleBlock : Theme -> Posix -> Element msg
dayTitleBlock theme date =
    row
        [ width fill
        , spacing 4
        , Font.size 20
        , Font.bold
        , paddingEach { top = 32, bottom = 8, left = 0, right = 0 }
        , Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }
        , Border.color theme.light
        ]
        [ el [ width fill ] (text (formatWeekday date))
        , el [ alignRight ] (text (formatDate date))
        ]


sourceBlock : Theme -> Element msg
sourceBlock theme =
    row [ width fill, centerX, paddingEach { top = 64, bottom = 16, left = 0, right = 0 } ]
        [ link
            [ htmlAttribute (Html.Attributes.target "_blank")
            , htmlAttribute (Html.Attributes.rel "noopener")
            , Font.color theme.accent
            , Font.underline
            , centerX
            ]
            { url = "https://github.com/alexeypegov/belgrade-imax"
            , label = text "Izvorni kod"
            }
        ]


timeCell : Theme -> Maybe SessionDetailsState -> Element msg
timeCell theme value =
    case value of
        Just state ->
            case state of
                SessionDetailsSuccess details ->
                    el [ Font.color theme.light, alignTop ] (text (formatTime details.session.showtime))

                SessionDetailsFailure ->
                    Element.none

        Nothing ->
            Element.none


titleCell : Theme -> Maybe SessionDetailsState -> Element msg
titleCell theme value =
    case value of
        Just state ->
            case state of
                SessionDetailsSuccess details ->
                    paragraph [ width fill ] [ text details.film.title ]

                SessionDetailsFailure ->
                    el [] (text "Greška...")

        Nothing ->
            el [ Font.color theme.light ] (text "• • •")


availableBlock : Theme -> Bool -> SessionDetails -> Element msg
availableBlock theme shouldPad details =
    let
        availPercent =
            (details.seatsAvailable * 100) // details.seatsTotal

        availPadded =
            if shouldPad then
                String.padLeft 2 ' ' (String.fromInt availPercent)

            else
                String.fromInt availPercent

        color =
            if availPercent > 70 then
                theme.green

            else if availPercent > 30 then
                theme.yellow

            else
                theme.red
    in
    el [ Font.color color ]
        (text (availPadded ++ "%"))


ticketLinkBlock : Theme -> SessionDetails -> Element msg
ticketLinkBlock theme details =
    link
        [ htmlAttribute (Html.Attributes.target "_blank")
        , htmlAttribute (Html.Attributes.rel "noopener")
        , Font.color theme.accent
        , Font.underline
        ]
        { url = "https://cineplexx.rs/purchase/wizard/" ++ details.id ++ "/tickets"
        , label = text "Karte"
        }


detailCell : Theme -> Bool -> Maybe SessionDetailsState -> Element msg
detailCell theme shouldPad value =
    case value of
        Just state ->
            case state of
                SessionDetailsSuccess details ->
                    row [ spacing 8 ]
                        [ availableBlock theme shouldPad details.session
                        , ticketLinkBlock theme details.session
                        ]

                SessionDetailsFailure ->
                    Element.none

        Nothing ->
            Element.none


narrowBlock : Theme -> Maybe SessionDetailsState -> Element msg
narrowBlock theme value =
    row [ width fill, spacing 8, paddingXY 0 16 ]
        [ el [ alignTop ] (timeCell theme value)
        , column [ width fill, spacing 8 ]
            [ titleCell theme value
            , detailCell theme False value
            ]
        ]


dayBlock : Context -> Dict String SessionDetailsState -> DaySchedule -> Element msg
dayBlock { theme, screenWidth } sessionDetails schedule =
    let
        enriched =
            List.map (\s -> ( s, Dict.get s.id sessionDetails )) schedule.sessions
    in
    if screenWidth < 460 then
        column [ width fill, paddingXY 0 16 ]
            (dayTitleBlock theme schedule.date
                :: List.map
                    (\e -> narrowBlock theme (Tuple.second e))
                    enriched
            )

    else
        column [ width fill, spacing 8 ]
            [ dayTitleBlock theme schedule.date
            , table [ width fill, spacing 8 ]
                { data = enriched
                , columns =
                    [ { header = none
                      , width = shrink
                      , view = \s -> timeCell theme (Tuple.second s)
                      }
                    , { header = none
                      , width = fill
                      , view = \s -> titleCell theme (Tuple.second s)
                      }
                    , { header = none
                      , width = shrink
                      , view = \s -> detailCell theme True (Tuple.second s)
                      }
                    ]
                }
            ]


scheduleBlock : Context -> Dict String SessionDetailsState -> List DaySchedule -> Element msg
scheduleBlock context sessionDetails days =
    column
        [ width fill
        , centerX
        , paddingXY 0 16
        , spacing 32
        ]
        (List.map (dayBlock context sessionDetails) days)


content : Context -> ScheduleState -> Dict String SessionDetailsState -> Element msg
content context scheduleState sessionDetails =
    case scheduleState of
        Loading ->
            el [ centerX, centerY, padding 50 ] <|
                paragraph
                    [ Font.size 32, Font.center ]
                    [ text "Učitavanje rasporeda..." ]

        Failure ->
            el [ centerX, centerY, padding 50 ] <|
                paragraph
                    [ Font.size 32, Font.center ]
                    [ text "Greška pri učitavanju rasporeda" ]

        Success schedule ->
            scheduleBlock context sessionDetails schedule


view : Model -> Html msg
view { context, schedule, sessionDetails } =
    layout [ width fill, Background.color context.theme.bg, Font.color context.theme.fg, Font.family [ Font.monospace ] ] <|
        column [ width (fill |> maximum 800), centerX, padding 16 ]
            [ title
            , content context schedule sessionDetails
            , sourceBlock context.theme
            ]
