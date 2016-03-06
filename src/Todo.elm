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
    }


type alias Task =
    { description : String
    , timer : Timer.Model
    , id : Int
    , stage : String
    , showControls : Bool
    , showStageOptions : Bool
    }


model : Model
model =
    { tasks = []
    , field = ""
    , nextId = 0
    , filter = "all"
    , showTaskInput = True
    }



-- timerView : Address Action -> Timer.Model -> Html
timerView address task =
    let
        { timer } = task
        minute = toString (timer.seconds // 60)
        second = timer.seconds % 60
        time = minute ++ ": " ++ (if second < 10 then ("0" ++ toString second) else (toString second))
    in
       span
            [ ]
            [ span
                [ Html.Events.onClick address (PauseResume task.id)
                , if timer.isRunning then class "icon-pause" else class "icon-play"
                ]
                [ ]
            , text time
            ]


-- changeTaskStage address task =
--     Html.Events.onWithOptions "change" { preventDefault = True, stopPropagation = True } Html.Events.targetValue (\v -> Signal.message address (ChangeStage v task.id))

changeTaskStage address task =
    Html.Events.on "click"  Html.Events.targetValue (\v -> Signal.message address (ChangeStage v task.id))


selectList address task =
    div
        [ changeTaskStage address task, AppStyles.selectStyles ]
        [ div [ value "todo" ] [ text "todo" ]
        , div [ value "inProgress" ] [ text "in progress" ]
        , div [ value "completed" ] [ text "completed" ]
        ]


taskController address task =
  div
    [ Html.Events.onClick address (ToggleStageSelection task.id)
    , class "controls"
    , AppStyles.taskControls task.showControls
    ]
    [ text ""
    , div
      [ ]
      [ (if task.showStageOptions then selectList address task else div [] []) ]
    ]


-- taskEntry : Address Action -> Task -> Html
taskEntry address filter task =
    div
        [ AppStyles.applyDisplayFiler filter task
        , Html.Events.onMouseOver address (ExposeControls task.id)
        , Html.Events.onMouseOut address (ExposeControls task.id)
        ]
        [ div
            [ class task.stage, AppStyles.taskRow ]
            [ taskController address task
            , text task.description
            , timerView address task
            ]

        ]



-- taskList : Address Action -> List Task -> Html
taskList address model =
    let
        someTasks = List.map (taskEntry address model.filter) model.tasks
    in
        div [] someTasks



-- onEnter : Address a -> a -> Attribute
onEnter address value =
    Html.Events.on
        "keydown"
        (Json.customDecoder Html.Events.keyCode is13)
        (\_ -> Signal.message address value)



-- is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()
    else
        Err "not the right key code"


type Action
    = AddTask
    | UpdateField String
    | Tick
    | Reset Int
    | PauseResume Int
    | ChangeStage String Int
    | ApplyTaskFilter String
    | ExposeControls Int
    | ToggleStageSelection Int
    | ShowInputField



-- incrementWatch : Task -> Task
incrementWatch task =
    let
        { timer } = task
    in
        if timer.isRunning then
            { task | timer = { seconds = timer.seconds + 1, isRunning = True } }
        else
            task



-- update : Action -> Model -> (Model, Effects a)
update action model =
    case action of
        AddTask ->
            ( { model
                | tasks =
                    model.tasks
                        ++ [ { description = model.field
                             , timer = Timer.init
                             , id = model.nextId
                             , stage = "todo"
                             , showControls = False
                             , showStageOptions = False
                             }
                           ]
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
                incrementedTasks = List.map incrementWatch model.tasks
            in
                ( { model | tasks = incrementedTasks }, Effects.none )

        PauseResume id ->
            let
                updateTaskTimer taskModel =
                    if taskModel.id == id then
                        let
                            { timer } = taskModel
                        in
                            { taskModel | timer = { timer | isRunning = not timer.isRunning } }
                    else
                        taskModel
            in
                ( { model | tasks = List.map updateTaskTimer model.tasks }, Effects.none )

        Reset id ->
            let
                resetTaskTimer taskModel =
                    if taskModel.id == id then
                        let
                            { timer } = taskModel
                        in
                            { taskModel | timer = { timer | seconds = 0 } }
                    else
                        taskModel
            in
                ( { model | tasks = List.map resetTaskTimer model.tasks }, Effects.none )

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

        ExposeControls id ->
            let toggleControls taskModel =
              if taskModel.id == id && taskModel.showControls == False then
                { taskModel | showControls = True }

              else
                { taskModel | showControls = False }
            in
              ( { model | tasks = List.map toggleControls model.tasks }, Effects.none )

        ToggleStageSelection id ->
            let toggleStageSelection taskModel =
              if taskModel.id == id then
                { taskModel | showStageOptions = not taskModel.showStageOptions }
              else
                taskModel
              in
                ( { model | tasks = List.map toggleStageSelection model.tasks }, Effects.none )

        ShowInputField ->
            ( {model | showTaskInput = True}, Effects.none )


applyTaskFilter address =
    div
        [ style [("display", "flex"), ("justify-content", "space-between") ] ]
        [ button [ Html.Events.onClick address (ApplyTaskFilter "all") ] [ text "ALL" ]
        , button [ Html.Events.onClick address (ApplyTaskFilter "todo") ] [ text "TO-DO" ]
        , button [ Html.Events.onClick address (ApplyTaskFilter "inProgress") ] [ text "IN PROGRESS" ]
        , button [ Html.Events.onClick address (ApplyTaskFilter "completed") ] [ text "COMPLETED" ]
        , span [ ] [ button [ AppStyles.plusButton, Html.Events.onClick address ShowInputField ] [text "+"] ]
        ]



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


-- view : Address Action -> Model -> Html
view address model =
    div
        [ style [ ( "padding", "24px" ) ] ]
        [ applyTaskFilter address
        , if model.showTaskInput then taskInputField address model else text ""
        , taskList address model
        ]
