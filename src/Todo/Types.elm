module Todo.Types (..) where

import Timer.Types


type alias Model =
    { tasks : List Task
    , field : String
    , nextId : Int
    , showCompleted : Bool
    , showTaskInput : Bool
    , featureTask : Task
    }


type alias Task =
    { description : String
    , timer : Timer.Types.Model
    , id : Int
    , completed : Bool
    }


type Action
    = AddTask
    | UpdateField String
    | Tick
    | CompleteTask Int
    | ApplyTaskFilter
    | ShowInputField
    | HandleFeatureTask Task
    | HandleTime Int Timer.Types.Action
