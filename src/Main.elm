port module Main exposing (..)

import Types exposing (..)
import Helper exposing (..)
import Views exposing (..)
import Html
import Time exposing (Time, every, second)
import Time.DateTime as DateTime exposing (DateTime)
import Rocket exposing (..)
import Task
import Notification exposing (defaultNotifyOption, notify)
import Focus exposing (Focus)
import Debug exposing (log, crash)


---- PORT ----


port fetchOffset : () -> Cmd msg


port acceptOffset : (Float -> msg) -> Sub msg



---- MODEL ----


init : ( Model, List (Cmd Msg) )
init =
    { now = DateTime.epoch
    , offset = 0
    , deadLines = []
    , permission = Default
    , input =
        { delta = 0
        , title = "タイトルだよ"
        , description = "説明だよ"
        }
    }
        => [ fetchOffset ()
           , Notification.fetchPermission ()
           ]



---- UPDATE ----


update : Msg -> Model -> ( Model, List (Cmd Msg) )
update msg model =
    case msg of
        Now now ->
            { model | now = now + model.offset |> DateTime.fromTimestamp }
                => []

        Offset offset ->
            { model | offset = offset }
                => [ Task.perform Now Time.now ]

        CheckDeadLines now ->
            let
                ( model_, cmds ) =
                    update (Now now) model

                notifications =
                    List.filter (isOver model.now) model.deadLines
                        |> List.map toNotifyOption
                        |> List.map (notify model.permission)
            in
                model_ => cmds ++ notifications

        CheckPermission permission ->
            { model | permission = permission }
                => case permission of
                    Default ->
                        [ Notification.requestPermission () ]

                    _ ->
                        []

        SetDelta ->
            let
                _ =
                    DateTime.toISO8601 model.now |> log "nowだよ"

                _ =
                    model.input.delta |> log "deltaだよ"

                _ =
                    DateTime.addSeconds model.input.delta model.now
                        |> DateTime.toISO8601
                        |> log "足した後"
            in
                { model
                    | deadLines =
                        { title = model.input.title
                        , description = model.input.description
                        , onSet = model.now
                        , time = DateTime.addSeconds model.input.delta model.now
                        }
                            :: model.deadLines
                }
                    => []

        Scroll Hour Up ->
            Focus.update inputHourFocus ((+) 1) model
                => []

        Scroll Hour Down ->
            Focus.update inputHourFocus (flip (-) 1) model
                => []

        Scroll Minute Up ->
            Focus.update inputMinuteFocus ((+) 1) model
                => []

        Scroll Minute Down ->
            Focus.update inputMinuteFocus (flip (-) 1) model
                => []

        Scroll Second Up ->
            Focus.update inputSecondFocus ((+) 1) model
                => []

        Scroll Second Down ->
            Focus.update inputSecondFocus (flip (-) 1) model
                => []

        SetInputHour num ->
            Focus.set inputHourFocus num model
                => []

        SetInputMinute num ->
            Focus.set inputMinuteFocus num model
                => []

        SetInputSecond num ->
            Focus.set inputSecondFocus num model
                => []

        StopAlerm ->
            { model | deadLines = List.filter (isOver model.now >> not) model.deadLines }
                => []


isOver : DateTime -> DeadLine -> Bool
isOver now { time } =
    case DateTime.compare now time of
        LT ->
            False

        EQ ->
            True

        GT ->
            True


toNotifyOption : DeadLine -> NotifyOption
toNotifyOption { title, description } =
    { defaultNotifyOption
        | title = title
        , body = Just description
        , icon = Just "/favicon.ico"
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ acceptOffset Offset
        , every second CheckDeadLines
        , Sub.map CheckPermission Notification.permission
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init |> Rocket.batchInit
        , update = update >> Rocket.batchUpdate
        , subscriptions = subscriptions
        }
