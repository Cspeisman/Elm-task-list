import StartApp
import Time
import Debug
import Html
import Html.Events
import Effects exposing (Effects)

type alias Model = {seconds : Int, isRunning : Bool}


type Action
  = Increment
  | PauseResume
  | Reset

update action model =
  case action of
    Increment ->
      if model.isRunning then ({model | seconds = model.seconds + 1}, Effects.none) else (model, Effects.none)

    PauseResume ->
      ({ model | isRunning = not model.isRunning }, Effects.none)

    Reset ->
      ({model | seconds = 0}, Effects.none)


view address model =
  let
    minute = toString (model.seconds // 60)
    second = model.seconds % 60
    time = minute ++ ": " ++ (if second < 10 then ("0" ++ toString second) else (toString second))
  in
  Html.div
    [ ]
    [ Html.text time
    , Html.button [ Html.Events.onClick address PauseResume ] [ Html.text (if model.isRunning then "pause" else "resume") ]
    , Html.button [ Html.Events.onClick address Reset ] [ Html.text "reset"]
    ]


app =
  StartApp.start {
    init = (Model 0 True, Effects.none)
    , view = view
    , update = update
    , inputs = [Signal.map (\_ -> Increment) (Time.every Time.second)] }



main =
  app.html
