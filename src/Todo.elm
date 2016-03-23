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
import AppStyles
import DynamicStyle
import Maybe
import String
import Helpers
import List.Extra exposing (getAt)
import Effects exposing (Effects)


-- Model

type alias Model =
    { tasks : List Task
    , field : String
    , nextId : Int
    , filter : String
    , showTaskInput : Bool
    , featureTask : Maybe Task
    }


type alias Task =
    { description : String
    , timer : Timer.Model
    , id : Int
    , stage : String
    }


model : Model
model =
    { tasks = []
    , field = ""
    , nextId = 0
    , filter = "all"
    , showTaskInput = True
    , featureTask = Maybe.Just {description = "What needs to get done?", timer = Timer.init, id = 0, stage = "todo"}
    }


-- Update

type Action
    = AddTask
    | UpdateField String
    | Tick
    | CompleteTask Int
    | ApplyTaskFilter String
    | ShowInputField
    | HandleFeatureTask (Maybe Task)
    | HandleTime Int Timer.Action


update : Action -> Model -> (Model, Effects a)
update action model =
    case action of
        AddTask ->
            ( { model
                | tasks =
                    List.append
                        [ { description = model.field
                          , timer = Timer.init
                          , id = model.nextId
                          , stage = "active"
                          } ]
                        model.tasks

                , nextId = model.nextId + 1
                , field = ""
                , showTaskInput = False
              }
            , Effects.none
            )

        UpdateField str ->
            ( { model | field = str }, Effects.none )

        Tick ->
            let
                incrementedTasks = List.map incrementTimer model.tasks
                featureTasks = List.filter (findFeatureTask model.featureTask) incrementedTasks
                task = getAt featureTasks 0
            in
                if task /= Maybe.Nothing then
                  ( { model | tasks = incrementedTasks, featureTask = task }, Effects.none)
                else
                  ( { model | tasks = incrementedTasks }, Effects.none)

        CompleteTask id ->
            let
                compleTask task =
                    let
                        { timer } = task
                        stage = if task.stage == "completed" then "active" else "completed"
                    in
                        if task.id == id then { task | stage = stage, timer = {timer | isRunning = False } } else task
            in
                ( { model | tasks = List.map compleTask model.tasks }, Effects.none )

        ApplyTaskFilter str ->
            ( { model | filter = str }, Effects.none )

        ShowInputField ->
            ( {model | showTaskInput = True}, Effects.none )

        HandleFeatureTask task ->
          ( {model | featureTask = task}, Effects.none)

        HandleTime id act ->
          let
              updateTaskTimer taskModel =
                  if taskModel.id == id then
                      let
                          { timer } = taskModel
                      in
                          { taskModel | timer = Timer.update act timer}
                  else
                      taskModel
          in
              ( { model | tasks = List.map updateTaskTimer model.tasks }, Effects.none )


incrementTimer : Task -> Task
incrementTimer task =
    let
        { timer } = task
    in
        if timer.isRunning then
            { task | timer = Timer.update Timer.Increment timer }
        else
            task


findFeatureTask : Maybe Task -> Task -> Bool
findFeatureTask featureTask task =
    let justFeatureTask = Helpers.fromJust featureTask
    in justFeatureTask.id == task.id


-- VIEW
taskEntry : Address Action -> String -> Task -> Html
taskEntry address filter task =
    div
        [ AppStyles.applyDisplayFiler filter task
        , Html.Events.onClick address (HandleFeatureTask (Maybe.Just task))
        , class "row"
        ]
        [ div
            [ class task.stage, AppStyles.taskRow ]
            [ section
                [ class "toggle-task" ]
                [ input [type' "checkbox", name "toggle", Html.Events.onClick address (CompleteTask task.id) ] [], span [] [ text task.description ] ]
            , Timer.view (Signal.forwardTo address (HandleTime task.id)) task.timer
            ]
        ]


taskList : Address Action -> Model -> Html
taskList address model =
    let
        someTasks = List.map (taskEntry address model.filter) model.tasks
    in
        div [] someTasks


onEnter : Address a -> a -> Attribute
onEnter address value =
    Html.Events.on
        "keydown"
        (Json.customDecoder Html.Events.keyCode Helpers.is13)
        (\_ -> Signal.message address value)


banner : Address Action -> Model -> Html
banner address model =
      let
          featureTask = Helpers.fromJust model.featureTask
          { timer } = featureTask
      in
          div
              [ AppStyles.banner ]
              [ div [ style [("text-align", "center"), ("font-size", "18px"), ("padding", "24px 0")] ] [ text featureTask.description ]
              , div [ style [("text-align", "center"), ("font-size", "56px"), ("font-weight", "300")] ] [ Timer.timerView timer ]
              , div
                  [ AppStyles.bannerControls ]
                  [ span (Timer.timerControls (Signal.forwardTo address (HandleTime featureTask.id)) featureTask.timer) [] ]
              ]


mainContent : Address Action -> Model -> Html
mainContent address model =
        div [ style [("width", "80%")]]
            [ banner address model
            , taskInputField address model
            , taskList address model
            ]


addButton : Address Action -> Html
addButton address =
    button [ Html.Events.onClick address AddTask ] [text "+ ADD"]


taskInputField : Address Action -> Model -> Html
taskInputField address model =
  div
      [ AppStyles.taskRow ]
      [ input
            [ id "new-todo"
            , placeholder "What needs to get done?"
            , autofocus True
            , value model.field
            , name "newTodo"
            , Html.Events.on "input" Html.Events.targetValue (\v -> Signal.message address (UpdateField v))
            , onEnter address AddTask
            , style [("font-size", "24px"), ("width", "90%")]
            ] [ ]
      , if (String.length model.field >= 1) then addButton address else text ""
      ]


sideNav : Address Action -> Model -> Html
sideNav address model =
    div
        [ style [("width", "20%")]]
        [ div [ AppStyles.label (model.filter == "active"), Html.Events.onClick address (ApplyTaskFilter "active") ] [ text "Active" ]
        , div [ AppStyles.label (model.filter == "completed"), Html.Events.onClick address (ApplyTaskFilter "completed") ] [ text "Completed" ]
        ]

view : Address Action -> Model -> Html
view address model =
    div
        [ style [("display", "flex")]]
        [ sideNav address model
        , mainContent address model
        ]


app =
    StartApp.start
    { init = ( model, Effects.none )
    , view = view
    , update = update
    , inputs = [ Signal.map (\_ -> Tick) (Time.every Time.second) ]
    }


main =
    app.html
