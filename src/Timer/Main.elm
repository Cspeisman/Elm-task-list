
import Effects exposing (Effects)
import Time
import StartApp
import Timer.View
import Timer.State
import Timer.Types
import Html

app =
  StartApp.start
    { init = ( Timer.State.init, Effects.none )
    , view = Timer.View.root
    , update = Timer.State.update
    , inputs = [ Signal.map (\_ -> Timer.Types.Increment) (Time.every Time.second) ]
    }

main =
  app.html
