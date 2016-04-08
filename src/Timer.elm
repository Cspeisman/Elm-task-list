module Timer (..) where

import StartApp
import Time
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import AppStyles
import Effects exposing (Effects)


type alias Model =
    { seconds : Int, isRunning : Bool }


type Action
    = Increment
    | PauseResume
    | Reset


init =
    { seconds = 0, isRunning = False }


update action model =
    case action of
        Increment ->
            if model.isRunning then
                { model | seconds = model.seconds + 1 }
            else
                model

        PauseResume ->
            { model | isRunning = not model.isRunning }

        Reset ->
            { model | seconds = 0 }


timerView model =
    let
        minute = toString (model.seconds // 60)

        second = model.seconds % 60

        time =
            minute
                ++ ": "
                ++ (if second < 10 then
                        ("0" ++ toString second)
                    else
                        (toString second)
                   )
    in
        text time


timerControls address model =
    [ Html.Events.onClick address PauseResume
    , if model.isRunning then
        class "icon-pause"
      else
        class "icon-play"
    ]


view address model =
    span
        [ AppStyles.timerStyles model.isRunning ]
        [ span
            [ AppStyles.taskListControls ]
            [ span (timerControls address model) [] ]
        , timerView model
        ]
