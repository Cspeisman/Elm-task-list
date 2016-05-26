module Timer.State (init,update) where

import Timer.Types exposing (..)
import Effects exposing (Effects)

init : Model
init =
    { seconds = 0, isRunning = False }


update : Action -> Model -> ( Model, Effects Action )
update action model =
    case action of
        Increment ->
            if model.isRunning then
                ({ model | seconds = model.seconds + 1 }, Effects.none)
            else
                (model, Effects.none)

        PauseResume ->
            ({ model | isRunning = not model.isRunning }, Effects.none)
