module Todo (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Signal exposing (Signal, Address)
import Debug exposing (log)
import StartApp.Simple as StartApp

main = StartApp.start { model = model, view = view, update = update }

type alias Model = { tasks : List String , field : String}

model = { tasks = [] , field = ""}

entryTask address task =
    li [] [ text task ]

taskList address tasks =
    let someTasks = List.map (entryTask address) tasks
    in  ul [] someTasks

onEnter address value =
    on "keydown"
        (Json.customDecoder keyCode is13)
        (\_ -> Signal.message address value)

is13 code =
    if code == 13
    then Ok ()
    else Err "not the right key code"

view address model =
    div []
        [ input
            [ id "new-todo"
            , placeholder "What needs to be done?"
            , autofocus True
            , value model.field
            , name "newTodo"
            , on "input" targetValue (\v -> Signal.message address (UpdateField v))
            , onEnter address AddTask]
            []
        , button [ onClick address AddTask ] [ text "Add Task" ]
        , taskList address model.tasks]

type Action = AddTask | UpdateField String

update action model =
    case action of
        AddTask ->
            { model | tasks = model.tasks ++ [ model.field ], field = "" }
        UpdateField str ->
            log "called" { model | field = str }
