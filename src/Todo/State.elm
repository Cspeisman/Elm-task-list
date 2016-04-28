module Todo.State (..) where

import Todo.Types exposing (..)
import Timer.State
import Timer.Types
import Task
import Effects exposing (Effects)
import List.Extra exposing (getAt)

model : Model
model =
    { tasks = []
    , field = ""
    , nextId = 0
    , showCompleted = False
    , showTaskInput = True
    , featureTask = defaultFeatureTask
    }


defaultFeatureTask =
    { description = "What needs to get done?", timer = Timer.State.init, id = -1, completed = False }



update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        AddTask ->
            ( { model
                | tasks =
                    { description = model.field
                    , timer = Timer.State.init
                    , id = model.nextId
                    , completed = False
                    }
                        :: model.tasks
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

                task = Maybe.withDefault defaultFeatureTask (getAt featureTasks 0)
            in
                ( { model | tasks = incrementedTasks, featureTask = task }, Effects.none )

        CompleteTask id ->
            let
                compleTask task =
                    let
                        { timer } = task
                    in
                        if task.id == id then
                            { task | completed = not task.completed, timer = { timer | isRunning = False } }
                        else
                            task
            in
                ( { model | tasks = List.map compleTask model.tasks }, Effects.none )

        ApplyTaskFilter ->
            ( { model | showCompleted = not model.showCompleted }, Effects.none )

        ShowInputField ->
            ( { model | showTaskInput = True }, Effects.none )

        HandleFeatureTask task ->
            ( { model | featureTask = task }, Effects.none )

        HandleTime id act ->
            let
                updateTaskTimer taskModel =
                    if taskModel.id == id then
                        let
                            { timer } = taskModel
                        in
                            { taskModel | timer = Timer.State.update act timer }
                    else
                        taskModel

                updatedTasksStuff = List.map updateTaskTimer model.tasks

                featureTasks = List.filter (findFeatureTask model.featureTask) updatedTasksStuff

                task = Maybe.withDefault defaultFeatureTask (getAt featureTasks 0)
            in
                ( { model | tasks = updatedTasksStuff }, Effects.task <| Task.succeed (HandleFeatureTask task) )


incrementTimer : Task -> Task
incrementTimer task =
    let
        { timer } = task
    in
        if timer.isRunning then
            { task | timer = Timer.State.update Timer.Types.Increment timer }
        else
            task


findFeatureTask : Task -> Task -> Bool
findFeatureTask featureTask task =
    let
        justFeatureTask = featureTask
    in
        justFeatureTask.id == task.id
