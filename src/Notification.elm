port module Notification exposing (..)

import Types exposing (NotifyOption, Permission(..))
import Debug exposing (log, crash)


---- PORT ----


port fetchPermission : () -> Cmd msg


port requestPermission : () -> Cmd msg


port acceptPermission : (String -> msg) -> Sub msg


port notify_ : NotifyOption -> Cmd msg


notify : Permission -> NotifyOption -> Cmd msg
notify permission option =
    case permission of
        Granted ->
            notify_ option

        _ ->
            Cmd.none


permission : Sub Permission
permission =
    acceptPermission
        (\label ->
            case label of
                "default" ->
                    Default

                "granted" ->
                    Granted

                "denied" ->
                    Denied

                "unsupported" ->
                    Unsupported

                _ ->
                    crash "Unexpected Notification Permission."
        )


defaultNotifyOption : NotifyOption
defaultNotifyOption =
    { title = ""
    , body = Nothing
    , tag = Nothing
    , icon = Nothing
    }
