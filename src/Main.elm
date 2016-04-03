module TaskApp (..) where

import Effects exposing (Effects)
import Task
import StartApp
import Todo exposing (model, view, update, Action)
import Time

app =
    StartApp.start
    { init = ( model, Effects.none )
    , view = view
    , update = update
    , inputs = [ Signal.map (\_ -> Todo.Tick) (Time.every Time.second) ]
    }

main =
    app.html

port tasks : Signal (Task.Task Effects.Never ())
port tasks =
    app.tasks
