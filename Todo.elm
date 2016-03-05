module Todo (..) where

import Timer
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
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
  , id : Int
  }


model : Model
model =
    { tasks = []
    , field = ""
    , nextId = 0
    }


-- timerView : Address Action -> Timer.Model -> Html
timerView address task =
  let
    {timer} = task
    minute = toString (timer.seconds // 60)
    second = timer.seconds % 60
    time = minute ++ ": " ++ (if second < 10 then ("0" ++ toString second) else (toString second))
  in
    div
      [ ]
      [ text time
      , button [ Html.Events.onClick address (PauseResume task.id) ] [ text (if timer.isRunning then "pause" else "resume") ]
      , button [ Html.Events.onClick address (Reset task.id)] [ text "reset"]
      ]


-- entryTask : Address Action -> Task -> Html
entryTask address task =
    div
      [ ]
      [
        li [] [ text task.description ]
      , timerView address task
      ]



-- taskList : Address Action -> List Task -> Html
taskList address tasks =
  let
    someTasks = List.map (entryTask address) tasks
  in
    ul [] someTasks


-- onEnter : Address a -> a -> Attribute
onEnter address value =
    Html.Events.on "keydown"
      (Json.customDecoder Html.Events.keyCode is13)
      (\_ -> Signal.message address value)


-- is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()
    else
        Err "not the right key code"


type Action id
    = AddTask
    | UpdateField String
    | Tick
    | Reset id
    | PauseResume id



-- incrementWatch : Task -> Task
incrementWatch task =
  let
    {timer} = task
  in
    if timer.isRunning then
      { task | timer = {seconds = timer.seconds + 1, isRunning = True}}
    else
      task


-- update : Action -> Model -> (Model, Effects a)
update action model =
  case action of
    AddTask ->
      ({ model
        | tasks = model.tasks ++ [
            {description = model.field
            , timer = Timer.init
            , id = model.nextId}
          ]
        , nextId = model.nextId + 1
        , field = "" }
        , Effects.none
      )

    UpdateField str ->
      ({ model | field = str }, Effects.none)

    Tick ->
      let
        incrementedTasks = List.map incrementWatch model.tasks
      in
        ({model | tasks = incrementedTasks}, Effects.none)

    PauseResume id ->
      let
        updateTaskTimer taskModel =
          if taskModel.id == id then
            let { timer } = taskModel
            in { taskModel | timer = { timer | isRunning = not timer.isRunning } }
          else
            taskModel
      in
        ({model | tasks = List.map updateTaskTimer model.tasks}, Effects.none)

    Reset id ->
      let
        resetTaskTimer taskModel =
          if taskModel.id == id then
            let { timer } = taskModel
            in { taskModel | timer = { timer | seconds = 0 } }
          else
            taskModel
      in
      ({model | tasks = List.map resetTaskTimer model.tasks}, Effects.none)



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
        , Html.Events.on "input" Html.Events.targetValue (\v -> Signal.message address (UpdateField v))
        , onEnter address AddTask ]
        [ ]
      , button [ Html.Events.onClick address AddTask ] [ text "Add Task" ]
      , taskList address model.tasks
      ]
