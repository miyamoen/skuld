module View exposing (..)

import Types exposing (..)
import Helper exposing (..)
import View.Svg exposing (clock)
import View.Stylesheet as Stylesheet exposing (Styles(..), stylesheet)
import Time.DateTime as DateTime exposing (DateTime)
import Html exposing (Html)
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Element.Events exposing (onInput, on, targetValue, onClick)
import Json.Decode as Json
import Time.DateTime as DateTime
import Focus
import Debug exposing (log, crash)


view : Model -> Html Msg
view model =
    Element.viewport stylesheet <|
        column None
            [ height <| fill 1
            , width <| fill 1
            , verticalCenter
            , center
            , spacingXY 25 25
            ]
            [ clock model.now
            , control model
            , paragraph None [] [ text <| DateTime.toISO8601 model.now ]
            ]



---- INPUT ----


control : Model -> Element Styles variation Msg
control model =
    let
        upDown delta =
            if delta >= 0 then
                Down
            else
                Up

        toInt str =
            String.toInt str
                |> Result.withDefault 0

        numberInput max scroll num =
            number NumberInput
                [ Attrs.min "0"
                , Attrs.max max
                , onMouseWheel (upDown >> Scroll scroll)
                , width <| fill 1
                , center
                ]
                num
    in
        column None
            [ spacing 10 ]
            [ case model.deadLine of
                Nothing ->
                    empty

                Just line ->
                    restTime model.now line
            , row None
                [ minHeight <| px 50
                ]
                [ numberInput "99" Hour (Focus.get inputHourFocus model)
                , numberInput "59" Minute (Focus.get inputMinuteFocus model)
                , numberInput "59" Second (Focus.get inputSecondFocus model)
                ]
            , text "Start"
                |> el Button
                    [ width <| fill 1
                    , onClick SetDelta
                    ]
                |> button
            , text "Stop"
                |> el Button
                    [ width <| fill 1
                    , onClick StopAlerm
                    ]
                |> button
            ]


onChange : (String -> msg) -> Attribute variation msg
onChange tagger =
    on "change" (Json.map tagger targetValue)


onMouseWheel : (Float -> msg) -> Attribute variation msg
onMouseWheel tagger =
    on "mousewheel" (Json.map tagger deltaY)


deltaY : Json.Decoder Float
deltaY =
    Json.field "deltaY" Json.float


number : style -> List (Attribute variation msg) -> Int -> Element style variation msg
number elem attrs content =
    node "input" <|
        el elem (type_ "number" :: value (toString content) :: attrs) empty


restTime : DateTime -> DeadLine -> Element Styles variation msg
restTime now { time } =
    let
        { hours, minutes, seconds } =
            DateTime.delta time now
    in
        [ hours, minutes % 60, seconds % 60 ]
            |> List.map (toString >> String.padLeft 2 '0')
            |> String.join ":"
            |> text
            |> el Stylesheet.DeadLine
                [ width <| fill 1
                , height <| px 40
                ]
