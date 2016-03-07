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
import Effects exposing (Effects)


main =
    app.html


app =
    StartApp.start
        { init = ( model, Effects.none )
        , view = view
        , update = update
        , inputs = [ Signal.map (\_ -> Tick) (Time.every Time.second) ]
        }


type alias Model =
    { tasks : List Task
    , field : String
    , nextId : Int
    , filter : String
    , showTaskInput : Bool
    , featureTask : Task
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
    , featureTask = {description = "Enter a new task", timer = Timer.init, id = 0, stage = "todo"}
    }


changeTaskStage address task =
    Html.Events.on "click"  Html.Events.targetValue (\v -> Signal.message address (ChangeStage v task.id))


selectList : Address Action -> Task -> Html
selectList address task =
    div
        [ changeTaskStage address task, AppStyles.selectStyles ]
        [ div [ value "todo" ] [ text "todo" ]
        , div [ value "inProgress" ] [ text "in progress" ]
        , div [ value "completed" ] [ text "completed" ]
        ]


taskEntry : Address Action -> String -> Task -> Html
taskEntry address filter task =
    div
        [ AppStyles.applyDisplayFiler filter task
        , Html.Events.onClick address (HandleFeatureTask task)
        ]
        [ div
            [ class task.stage, AppStyles.taskRow ]
            [ text task.description
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
        (Json.customDecoder Html.Events.keyCode is13)
        (\_ -> Signal.message address value)



is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()
    else
        Err "not the right key code"


incrementTimer : Task -> Task
incrementTimer task =
    let
        { timer } = task
    in
        if timer.isRunning then
            { task | timer = Timer.update Timer.Increment timer }
        else
            task

type Action
    = AddTask
    | UpdateField String
    | Tick
    | ChangeStage String Int
    | ApplyTaskFilter String
    | ShowInputField
    | HandleFeatureTask Task
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
                          , stage = "todo"
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
            in
                ( { model | tasks = incrementedTasks }, Effects.none )

        ChangeStage str id ->
            let
                switchStage taskModel =
                    if taskModel.id == id then
                        { taskModel | stage = str }
                    else
                        taskModel
            in
                ( { model | tasks = List.map switchStage model.tasks }, Effects.none )

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
                          { taskModel | timer = Timer.update act timer }
                  else
                      taskModel
          in
              ( { model | tasks = List.map updateTaskTimer model.tasks }, Effects.none )


banner : Address Action -> Model -> Html
banner address model =
  let
      { featureTask } = model
      { timer } = featureTask
  in
    div
      [ AppStyles.banner ]
      [ div [ style [("text-align", "center"), ("font-size", "18px"), ("padding", "24px 0")] ] [ text featureTask.description ]
      , div [ style [("text-align", "center"), ("font-size", "56px"), ("font-weight", "300")] ] [ text (toString timer.seconds) ]
      , div [ class "icon-pause", style [("color", "white"), ("text-align", "center"), ("font-size", "36px"), ("padding", "24px 0")]] [ ]
      , applyTaskFilter address
      ]


applyTaskFilter : Address Action -> Html
applyTaskFilter address =
    div
        [ style [ ("position", "relative"), ("background", "rgba(239, 239, 239, 0.5)")] ]
        [ button [ AppStyles.label, Html.Events.onClick address (ApplyTaskFilter "all") ] [ text "ALL" ]
        , button [ AppStyles.label, Html.Events.onClick address (ApplyTaskFilter "todo") ] [ text "TO-DO" ]
        , button [ AppStyles.label, Html.Events.onClick address (ApplyTaskFilter "inProgress") ] [ text "IN PROGRESS" ]
        , button [ AppStyles.label, Html.Events.onClick address (ApplyTaskFilter "completed") ] [ text "COMPLETED" ]
        , span [style [("position", "absolute"), ("right", "0"), ("bottom", "-23px")]] [ button [ AppStyles.plusButton, Html.Events.onClick address ShowInputField ] [text "+"] ]
        ]


taskInputField : Address Action -> Model -> Html
taskInputField address model =
  input
      [ id "new-todo"
      , placeholder "What needs to be done?"
      , autofocus True
      , value model.field
      , name "newTodo"
      , Html.Events.on "input" Html.Events.targetValue (\v -> Signal.message address (UpdateField v))
      , onEnter address AddTask
      , AppStyles.taskRow
      ]
      [ ]


view : Address Action -> Model -> Html
view address model =
    div
        [ ]
        [ banner address model
        , if model.showTaskInput then taskInputField address model else text ""
        , taskList address model
        ]
