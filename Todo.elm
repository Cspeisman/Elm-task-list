module Todo (..) where

import Timer
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Signal exposing (Signal, Address)
import Debug
import StartApp
import Time
import Effects exposing (Effects)


main =
  app.html


app =
    StartApp.start {
        init = (model, Effects.none)
      , view = view
      , update = update
      , inputs = [Signal.map (\_ -> Tick) (Time.every Time.second)]
    }


type alias Model =
    { tasks : List Task
    , field : String
    , nextId : Int
    }


type alias Task =
  {
    description : String
  , timer : Timer.Model
  }


model : Model
model =
    { tasks = []
    , field = ""
    , nextId = 0
    }


-- entryTask : Address Action -> String -> Html
entryTask address task =
  let
    {description, timer} = task
  in
    div
      [ ]
      [
        li [] [ text task.description ]
      , text (toString timer.seconds)
      ]



-- taskList : Address Action -> List String -> Html
taskList address tasks =
  let
    someTasks = List.map (entryTask address) tasks
  in
    ul [] someTasks


onEnter : Address a -> a -> Attribute
onEnter address value =
    on "keydown"
      (Json.customDecoder keyCode is13)
      (\_ -> Signal.message address value)


is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()
    else
        Err "not the right key code"


type Action
    = AddTask
    | UpdateField String
    | Tick




incrementWatch task =
  let
    {timer} = task
  in
    { task | timer = {seconds = timer.seconds + 1, isRunning = True}}


-- update : Action -> Model -> (Model, Effects a)
update action model =
  case action of
    AddTask ->
      ({ model | tasks = model.tasks ++ [ {description = model.field, timer = Timer.init} ], field = "" }, Effects.none)

    UpdateField str ->
      ({ model | field = str }, Effects.none)

    Tick ->
      let
        bar = List.map incrementWatch model.tasks
      in
        ({model | tasks = bar}, Effects.none)


-- view : Address Action -> Model -> Html
view address model =
  div
    [ ]
      [ input
        [ id "new-todo"
        , placeholder "What needs to be done?"
        , autofocus True
        , value model.field
        , name "newTodo"
        , on "input" targetValue (\v -> Signal.message address (UpdateField v))
        , onEnter address AddTask ]
        [ ]
      , button [ onClick address AddTask ] [ text "Add Task" ]
      , taskList address model.tasks
      ]
