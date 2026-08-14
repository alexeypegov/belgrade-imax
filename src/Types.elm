module Types exposing (Context, DaySchedule, Film, Model, ScheduleState(..), Session, SessionDetails, SessionDetailsState(..), SessionDetailsWrapper)

import Dict exposing (Dict)
import Theme exposing (Theme)
import Time exposing (Posix)


type alias Film =
    { title : String
    , duration : String
    }


type alias SessionDetailsWrapper =
    { session : SessionDetails
    , film : Film
    }


type alias SessionDetails =
    { id : String
    , sessionId : String
    , showtime : Posix
    , seatsAvailable : Int
    , seatsTotal : Int
    }


type alias Session =
    { id : String
    , technologies : List String
    }


type alias DaySchedule =
    { date : Posix
    , sessions : List Session
    }


type ScheduleState
    = Loading
    | Failure
    | Success (List DaySchedule)


type SessionDetailsState
    = SessionDetailsFailure
    | SessionDetailsSuccess SessionDetailsWrapper


type alias Context =
    { theme : Theme
    , screenWidth : Int
    }


type alias Model =
    { context : Context
    , schedule : ScheduleState
    , sessionDetails : Dict String SessionDetailsState
    }
