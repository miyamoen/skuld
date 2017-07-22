module View.Stylesheet exposing (Styles(..), stylesheet)

import View.Colors exposing (colors)
import Style exposing (..)
import Style.Font as Font
import Style.Color as Color
import Style.Shadow as Shadow
import Style.Border as Border
import Style.Transition as Transition


type Styles
    = None
    | NumberInput
    | Button
    | DeadLine


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
            , Style.shadows
                [ Shadow.box
                    { offset = ( 0, 6 )
                    , size = 0
                    , blur = 0
                    , color = colors.buttonShadow
                    }
                ]

            -- , Shadow.glow colors.buttonShadow 4
            , Style.cursor "pointer"
            , Border.none
            , Border.rounded 10
            , Transition.transitions
                [ { delay = 0
                  , duration = 200
                  , easing = "ease"
                  , props = [ "box-shadow", "transform" ]
                  }
                , { delay = 0
                  , duration = 400
                  , easing = "ease"
                  , props = [ "background" ]
                  }
                ]
            , hover
                [ Style.translate 0 1 0
                , Style.shadows
                    [ Shadow.box
                        { offset = ( 0, 5 )
                        , size = 0
                        , blur = 0
                        , color = colors.buttonShadow
                        }
                    ]
                ]
            , pseudo "active"
                [ Color.background colors.buttonPush
                , Style.translate 0 6 0
                , Style.shadows
                    [ Shadow.box
                        { offset = ( 0, 0 )
                        , size = 0
                        , blur = 0
                        , color = colors.buttonShadow
                        }
                    ]

                -- , Style.shadows
                --     [ Shadow.drop
                --         { offset = ( 0, 1 )
                --         , blur = 0
                --         , color = colors.buttonShadow
                --         }
                --     ]
                ]
            ]
        , style DeadLine
            [ Font.size 30 ]
        ]
