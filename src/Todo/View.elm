module Todo.View (..) where

import Todo.State exposing (..)
import Todo.Types exposing (..)
import Timer.View
import Signal exposing (Signal, Address)
import Json.Decode as Json
import AppStyles
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events
import Html.Lazy
import Helpers
import String


taskEntry : Address Action -> Model -> Task -> Html
taskEntry address model task =
    div
        [ AppStyles.displayTask (model.showCompleted == task.completed)
        , Html.Events.onClick address (HandleFeatureTask task)
        ]
        [ div
            [ AppStyles.taskRow ]
            [ section
                [ class "toggle-task" ]
                [ input
                    [ type' "checkbox"
                    , name "toggle"
                    , id (toString task.id)
                    , Html.Events.onClick address (CompleteTask task.id)
                    , checked task.completed
                    ]
                    []
                , span [ class "task-text" ] [ text task.description ]
                ]
            , Timer.View.root (Signal.forwardTo address (HandleTime task.id)) task.timer
            ]
        ]


taskList : Address Action -> Model -> Html
taskList address model =
    let
        someTasks = List.map (taskEntry address model) model.tasks
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
        featureTask = model.featureTask

        { timer } = featureTask
    in
        div
            [ AppStyles.banner (featureTask.id >= 0 && timer.isRunning) ]
            [ div [ style [ ( "text-align", "center" ), ( "font-size", "18px" ), ( "font-weight", "bold" ), ( "padding", "24px 0" ), ("background-color", "#5299FD") ] ] [ text featureTask.description ]
            , div [ style [ ( "text-align", "center" ), ( "font-size", "56px" ), ( "font-weight", "200" ), ("background-color", "#5299FD") ] ] [ Timer.View.timerView timer ]
            , div
                [ AppStyles.bannerControls ]
                [ span (Timer.View.timerControls (Signal.forwardTo address (HandleTime featureTask.id)) featureTask.timer) [] ]
            ]


mainContent : Address Action -> Model -> Html
mainContent address model =
    div
        [ style [ ( "width", "80%" ) ] ]
        [ banner address model
        , taskInputField address model
        , taskList address model
        ]


addButton : Address Action -> Html
addButton address =
    button [ Html.Events.onClick address AddTask, AppStyles.buttonStyle ] [ text "+ ADD" ]


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
            , style [ ( "font-size", "24px" ), ( "width", "75%" ) ]
            ]
            []
        , if (String.length model.field >= 1) then
            addButton address
          else
            text ""
        ]


sideNav : Address Action -> Model -> Html
sideNav address model =
    let
        activeCount = List.length (List.filter (\task -> task.completed == False) model.tasks) |> toString

        completedCount = List.length (List.filter (\task -> task.completed == True) model.tasks) |> toString
    in
        div
            [ style [ ( "min-width", "35%" ), ( "white-space", "nowrap" ), ( "border-right", "1px solid #eee" ) ] ]
            [ div [ AppStyles.label (not model.showCompleted), Html.Events.onClick address ApplyTaskFilter, class "icon-list" ] [ text ("Active" ++ " (" ++ activeCount ++ ")") ]
            , div [ AppStyles.label model.showCompleted, Html.Events.onClick address ApplyTaskFilter, class "icon-list" ] [ text ("Completed" ++ " (" ++ completedCount ++ ")") ]
            ]


view : Address Action -> Model -> Html
view address model =
    div
        [ style [ ( "display", "flex" ), ("min-height", "100vh") ] ]
        [ Html.Lazy.lazy2 sideNav address model
        , Html.Lazy.lazy2 mainContent address model
        ]
