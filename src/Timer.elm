module Timer (..) where

import StartApp
import Graphics.Element
import Time
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import AppStyles
import Effects exposing (Effects)


-- MODEL
type alias Model =
    { seconds : Int, isRunning : Bool }


type Action
    = Increment
    | PauseResume
    | Reset


init : Model
init =
    { seconds = 0, isRunning = False }


-- UPDATE
update : Action -> Model -> Model
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


-- VIEW
timerView : Model -> Html
timerView model =
    let
        minute = toString (model.seconds // 60)

        second = model.seconds % 60

        time =
            minute ++ ": " ++ (if second < 10 then ("0" ++ toString second) else (toString second))
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


view : Signal.Address Action -> Model -> Html
view address model =
    span
        [ AppStyles.timerStyles model.isRunning ]
        [ span
            [ AppStyles.taskListControls ]
            [ span (timerControls address model) [] ]
        , timerView model
        ]


-- IMPLEMENTATION STUFF
counts : Signal Model
counts =
  Signal.foldp (\_ model -> update Increment model) {seconds = 0, isRunning = True} (Time.fps 1)


main =
   Signal.map Graphics.Element.show (Signal.map .seconds counts)
