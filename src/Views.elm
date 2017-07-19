module Views exposing (..)

import Types exposing (..)
import Helper exposing (..)
import Time.DateTime as DateTime exposing (DateTime)
import Html exposing (Html)
import Element exposing (..)
import Element.Attributes as Attrs exposing (..)
import Element.Events exposing (onInput, on, targetValue, onClick)
import Style exposing (..)
import Style.Font as Font
import Style.Color as Color
import Style.Shadow as Shadow
import Graphics.Render as Graphics
    exposing
        ( filledAndBordered
        , filled
        , position
        , svg
        , angle
        , segment
        , styledLine
        , round
        , flat
        , square
        , smooth
        , sharp
        , bevel
        , solid
        , Form
        , group
        )
import Color exposing (rgba)
import Json.Decode as Json
import Time.DateTime as DateTime
import Focus
import Debug exposing (log, crash)


type Styles
    = None
    | NumberInput
    | Button


stylesheet : StyleSheet Styles variation
stylesheet =
    Style.stylesheet
        [ style None []
        , style NumberInput
            [ Font.size 30
            , Font.center
            ]
        , style Button
            [ Color.background colors.button
            , Color.text colors.buttonFont

            -- , Shadow.glow colors.buttonShadow 4
            , Style.cursor "pointer"

            -- , hover [ Color.background colors.blue1 ]
            , pseudo "active" [ Color.background colors.mauve ]
            ]
        ]


colors =
    { mauve = rgba 176 161 186 1
    , white = rgba 255 255 255 1
    , blue1 = rgba 165 181 191 1
    , blue2 = rgba 171 200 199 1
    , green1 = rgba 184 226 200 1
    , green2 = rgba 191 240 212 1
    , orange = rgba 200 100 100 1
    , face = rgba 150 171 180 1
    , second = rgba 200 100 100 1
    , minute = rgba 20 100 100 1
    , hour = rgba 200 200 100 1
    , button = rgba 90 122 179 1
    , buttonShadow = rgba 64 99 164 1
    , buttonFont = rgba 230 230 230 1
    }


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
            [ clock model
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

        numberInput max scroll focus =
            number NumberInput
                [ Attrs.min "0"
                , Attrs.max max
                , onMouseWheel (upDown >> Scroll scroll)
                , width <| fill 1
                , center
                ]
                (Focus.get focus model)
    in
        column None
            [ spacing 5 ]
            [ row None
                [ minHeight <| px 50
                ]
                [ numberInput "99" Hour inputHourFocus
                , numberInput "59" Minute inputMinuteFocus
                , numberInput "59" Second inputSecondFocus
                ]
            , text "Set Dead Line!"
                |> el Button
                    [ width <| fill 1
                    , onClick SetDelta
                    ]
                |> button
            , text "Stop Alerm!"
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



---- SVG ----


fromForms : Float -> Float -> List (Form msg) -> Element style variation msg
fromForms w h forms =
    group forms
        |> position ( w / 2, h / 2 )
        |> svg 1 1 w h
        |> Element.html


polar : ( Float, Float ) -> Form msg -> Form msg
polar p form =
    fromPolar p
        |> flip position form


clock : Model -> Element style variation msg
clock { now } =
    fromForms
        200
        200
        [ clockFace
        , clockHands now
        ]


clockFace : Form msg
clockFace =
    let
        hour theta =
            Graphics.circle 5
                |> filled (solid colors.white)
                |> polar ( 85, theta )

        face =
            Graphics.circle 95
                |> filledAndBordered
                    (solid colors.face)
                    5
                    (solid colors.green1)
    in
        group
            (face
                :: (List.range 0 11
                        |> List.map
                            (toFloat
                                >> (*) (2 * pi)
                                >> flip (/) 12
                                >> hour
                            )
                   )
            )


clockHands : DateTime -> Form msg
clockHands time =
    let
        style w col =
            { stroke = solid col
            , width = w
            , cap = Graphics.round
            , join = bevel
            , dashing = []
            , dashOffset = 0
            }

        second =
            DateTime.second time |> toFloat

        minute =
            (DateTime.minute time * 60 |> toFloat) + second

        hour =
            (DateTime.hour time * 60 * 60 |> toFloat) + minute

        secondHand =
            styledLine
                (segment ( 0, -5 ) ( 0, -90 ))
                (style 2 colors.second)

        minuteHand =
            styledLine
                (segment ( 0, -5 ) ( 0, -85 ))
                (style 5 colors.minute)

        hourHand =
            styledLine
                (segment ( 0, -5 ) ( 0, -50 ))
                (style 7.5 colors.hour)
    in
        group
            [ hourHand
                |> angle (2 * pi * hour / (12 * 3600))
            , minuteHand
                |> angle (2 * pi * minute / 3600)
            , secondHand
                |> angle (2 * pi * second / 60)
            ]
