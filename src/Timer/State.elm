module Timer.State (init,update) where

import Timer.Types exposing (..)

init : Model
init =
    { seconds = 0, isRunning = False }


update : Action -> Model -> Model
update action model =
    case action of
        Increment ->
            if model.isRunning then
                { model | seconds = model.seconds + 1 }
            else
                model

        PauseResume ->
            { model | isRunning = not model.isRunning }

        Reset ->
            { model | seconds = 0 }
