module Ui exposing (..)

import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html, details)
import Html.Attributes
import Theme exposing (Theme)
import Time exposing (Posix)
import TimeFormat exposing (formatDate, formatTime, formatWeekday, isConsecutiveDays, isWeekend)
import Types exposing (Context, DaySchedule, Model, ScheduleState(..), SessionDetails, SessionDetailsState(..))


smallScreenWidth : Int
smallScreenWidth =
    460


title : Element msg
title =
    el [ centerX, paddingXY 0 32 ] <|
        paragraph [ Font.size 32, Font.bold ]
            [ text "Raspored IMAX projekcija u Beogradu" ]


dayTitleBlock : Theme -> Posix -> Element msg
dayTitleBlock theme date =
    let
        bgColor =
            if isWeekend date then
                theme.weekendBg

            else
                theme.weekdayBg
    in
    row
        [ width fill
        , spacing 4
        , Font.size 20
        , Background.color bgColor
        , paddingXY 16 8
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
            , Font.size 16
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
                    el
                        [ Font.color theme.light
                        , alignTop
                        , paddingEach { left = 16, right = 0, top = 0, bottom = 0 }
                        ]
                        (text (formatTime details.session.showtime))

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


availableBlock : Theme -> SessionDetails -> Element msg
availableBlock theme details =
    let
        availPercent =
            (details.seatsAvailable * 100)
                // details.seatsTotal

        color =
            if availPercent > 70 then
                theme.green

            else if availPercent > 30 then
                theme.yellow

            else
                theme.red
    in
    el [ Font.color color ]
        (text (String.fromInt availPercent ++ "%"))


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
detailCell theme smallScreen value =
    let
        alignment =
            if smallScreen then
                alignLeft

            else
                alignRight
    in
    case value of
        Just state ->
            case state of
                SessionDetailsSuccess details ->
                    row
                        [ spacing 8
                        , alignment
                        , paddingEach { left = 0, right = 16, top = 0, bottom = 0 }
                        ]
                        [ availableBlock theme details.session
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
            , detailCell theme True value
            ]
        ]


dayBlock : Context -> Dict String SessionDetailsState -> DaySchedule -> Element msg
dayBlock { theme, screenWidth } sessionDetails schedule =
    let
        enriched =
            List.map (\s -> ( s, Dict.get s.id sessionDetails )) schedule.sessions
    in
    if screenWidth < smallScreenWidth then
        column [ width fill, paddingXY 0 16 ]
            (dayTitleBlock theme schedule.date
                :: List.map
                    (\e -> narrowBlock theme (Tuple.second e))
                    enriched
            )

    else
        column [ width fill, spacing 8, paddingXY 0 16 ]
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
                      , view = \s -> el [] (detailCell theme False (Tuple.second s))
                      }
                    ]
                }
            ]


gapSeparator : Theme -> Element msg
gapSeparator theme =
    let
        line =
            el
                [ width fill
                , height (px 2)
                , Background.color theme.light
                ]
                none
    in
    row
        [ width fill
        , spacing 16
        , paddingXY 16 0
        , Font.color theme.light
        , Font.size 28
        ]
        [ line
        , el [ Font.letterSpacing 8 ] (text "···")
        , line
        ]


withGaps : Context -> Dict String SessionDetailsState -> List DaySchedule -> List (Element msg)
withGaps context sessionDetails days =
    let
        render prev day =
            case prev of
                Just p ->
                    if not (isConsecutiveDays p.date day.date) then
                        [ gapSeparator context.theme, dayBlock context sessionDetails day ]

                    else
                        [ dayBlock context sessionDetails day ]

                Nothing ->
                    [ dayBlock context sessionDetails day ]
    in
    List.map2 render (Nothing :: List.map Just days) days
        |> List.concat


scheduleBlock : Context -> Dict String SessionDetailsState -> List DaySchedule -> Element msg
scheduleBlock context sessionDetails days =
    if List.isEmpty days then
        el [ centerX, paddingXY 0 32 ] <|
            paragraph [ Font.size 24 ]
                [ text "Za sada nema IMAX projekcija u rasporedu bioskopa :(" ]

    else
        column
            [ width fill
            , centerX
            , paddingXY 0 16
            , spacing 32
            ]
            (withGaps context sessionDetails days)


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
    let
        padding =
            if context.screenWidth < smallScreenWidth then
                ( 16, 0 )

            else
                ( 32, 16 )
    in
    layout [ width fill, Background.color context.theme.bg, Font.color context.theme.fg, Font.family [ Font.monospace ] ] <|
        column [ width (fill |> maximum 800), centerX, paddingXY 0 16 ]
            [ el [ width fill, paddingXY (Tuple.first padding) 0 ] title
            , el [ width fill, paddingXY (Tuple.second padding) 0 ] (content context schedule sessionDetails)
            , sourceBlock context.theme
            ]
