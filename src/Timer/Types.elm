module Timer.Types (..) where

type alias Model =
    { seconds : Int, isRunning : Bool }


type Action
    = Increment
    | PauseResume
    | Reset
