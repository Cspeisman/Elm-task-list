module Timer.View (..) where

import Timer.State exposing (..)
import Timer.Types exposing (..)
import AppStyles
import Signal
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events


timerView : Model -> Html
timerView model =
    let
        minute = toString (model.seconds // 60)

        second = model.seconds % 60

        time =
            minute ++ ":" ++ (if second < 10 then ("0" ++ toString second) else (toString second))
    in
        text time


timerControls : Signal.Address Action -> Model -> List Attribute
timerControls address model =
    [ Html.Events.onClick address PauseResume
    , if model.isRunning then
        class "icon-pause"
      else
        class "icon-play"
    ]


root : Signal.Address Action -> Model -> Html
root address model =
    span
        [ AppStyles.timerStyles model.isRunning ]
        [ span
            [ AppStyles.taskListControls ]
            [ span (timerControls address model) [] ]
        , timerView model
        ]
