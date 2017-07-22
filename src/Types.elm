module Types exposing (..)

import Time exposing (Time)
import Time.DateTime as DateTime exposing (DateTime, DateTimeDelta)


---- Main ----


type alias Model =
    { now : DateTime
    , offset : Float
    , deadLine : Maybe DeadLine
    , permission : Permission
    , input : Input
    }


type alias DeadLine =
    { title : String
    , description : String
    , time : DateTime
    , onSet : DateTime
    }


type alias Input =
    { delta : Delta
    , title : String
    , description : String
    }


type alias Delta =
    Int



---- Msg ----


type Msg
    = Now Time
    | Offset Float
    | CheckDeadLines Time
    | CheckPermission Permission
    | SetDelta
    | Scroll Tick Op
    | SetInputHour Int
    | SetInputMinute Int
    | SetInputSecond Int
    | StopAlerm


type Tick
    = Hour
    | Minute
    | Second


type Op
    = Up
    | Down



---- Notification ----


type Permission
    = Default
    | Granted
    | Denied
    | Unsupported


type alias NotifyOption =
    { title : String
    , body : Maybe String
    , tag : Maybe String
    , icon : Maybe String
    }
