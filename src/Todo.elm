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
    }



-- timerView : Address Action -> Timer.Model -> Html
timerView address task =
    let
        { timer } = task

        minute = toString (timer.seconds // 60)

        second = timer.seconds % 60

        time =
            minute
                ++ ": "
                ++ (if second < 10 then
                        ("0" ++ toString second)
                    else
                        (toString second)
                   )
    in
        span
            []
            [ span
                [ Html.Events.onClick address (PauseResume task.id)
                , (if timer.isRunning then
                    class "icon-pause"
                   else
                    class "icon-play"
                  )
                ]
                []
            , text time
              -- , button [ Html.Events.onClick address (Reset task.id)] [ text "reset"]
            ]


changeTaskStage address task =
    Html.Events.onWithOptions "change" { preventDefault = True, stopPropagation = True } Html.Events.targetValue (\v -> Signal.message address (ChangeStage v task.id))


selectList address task =
    select
        [ changeTaskStage address task ]
        [ option [ value "todo" ] [ text "todo" ]
        , option [ value "inProgress" ] [ text "in progress" ]
        , option [ value "completed" ] [ text "completed" ]
        ]



-- entryTask : Address Action -> Task -> Html
entryTask address filter task =
    div
        [ AppStyles.applyDisplayFiler filter task ]
        [ div
            [ class task.stage, AppStyles.taskRow ]
            [ text task.description
            , timerView address task
            ]
        ]



-- taskList : Address Action -> List Task -> Html
taskList address model =
    let
        someTasks = List.map (entryTask address model.filter) model.tasks
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
                             }
                           ]
                , nextId = model.nextId + 1
                , field = ""
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


applyTaskFilter address =
    div
        []
        [ button [ Html.Events.onClick address (ApplyTaskFilter "all") ] [ text "ALL" ]
        , button [ Html.Events.onClick address (ApplyTaskFilter "todo") ] [ text "TO-DO" ]
        , button [ Html.Events.onClick address (ApplyTaskFilter "inProgress") ] [ text "IN PROGRESS" ]
        , button [ Html.Events.onClick address (ApplyTaskFilter "completed") ] [ text "COMPLETED" ]
        ]



-- view : Address Action -> Model -> Html
view address model =
    div
        [ style [ ( "padding", "24px" ) ] ]
        [ input
            [ id "new-todo"
            , placeholder "What needs to be done?"
            , autofocus True
            , value model.field
            , name "newTodo"
            , Html.Events.on "input" Html.Events.targetValue (\v -> Signal.message address (UpdateField v))
            , onEnter address AddTask
            ]
            []
        , button [ Html.Events.onClick address AddTask ] [ text "Add Task" ]
        , applyTaskFilter address
        , h3 [] [ text model.filter ]
        , taskList address model
        ]
