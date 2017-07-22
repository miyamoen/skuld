module View.Svg exposing (..)

import Time.DateTime as DateTime exposing (DateTime)
import Element exposing (Element)
import Graphics.Render as Graphics exposing (..)
import View.Colors exposing (colors)
import Time.DateTime as DateTime


---- Transform ----


fromForms : Float -> Float -> List (Form msg) -> Element style variation msg
fromForms w h forms =
    group forms
        |> position ( w / 2, h / 2 )
        |> svg 1 1 w h
        |> Element.html



---- SVG ----


polar : ( Float, Float ) -> Form msg -> Form msg
polar p form =
    fromPolar p
        |> flip position form


clock : DateTime -> Element style variation msg
clock now =
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
            circle 5
                |> filled (solid colors.white)
                |> polar ( 85, theta )

        face =
            circle 95
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
