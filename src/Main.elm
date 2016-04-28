module TaskApp (..) where

import Effects exposing (Effects)
import Task
import Todo.Types
import StartApp
import Todo.State
import Todo.View
import Time


app =
    StartApp.start
        { init = ( Todo.State.model, Effects.none )
        , view = Todo.View.view
        , update = Todo.State.update
        , inputs = [ Signal.map (\_ -> Todo.Types.Tick) (Time.every Time.second) ]
        }


main =
    app.html


port tasks : Signal (Task.Task Effects.Never ())
port tasks =
    app.tasks
