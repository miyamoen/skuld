module Helper exposing (..)

import Types exposing (..)
import Focus exposing (Focus, (=>))


---- Focus ----


inputDeltaFocus : Focus Model Delta
inputDeltaFocus =
    Focus.create
        (.input >> .delta)
        (\f m ->
            let
                input =
                    m.input
            in
                { m | input = { input | delta = f input.delta } }
        )


inputHourFocus : Focus Model Int
inputHourFocus =
    let
        get d =
            d // 3600

        rest d =
            d % 3600

        update f d =
            (rest d) + f (get d) * 3600 |> floor 0
    in
        inputDeltaFocus => Focus.create get update


inputMinuteFocus : Focus Model Int
inputMinuteFocus =
    let
        get d =
            d % 3600 // 60

        rest d =
            (d // 3600) * 3600 + d % 60

        update f d =
            (rest d) + f (get d) * 60 |> floor 0
    in
        inputDeltaFocus => Focus.create get update


inputSecondFocus : Focus Model Int
inputSecondFocus =
    let
        get d =
            d % 60

        rest d =
            d - get d

        update f d =
            (rest d) + f (get d) |> floor 0
    in
        inputDeltaFocus => Focus.create get update


floor : comparable -> comparable -> comparable
floor f num =
    if num >= f then
        num
    else
        f
