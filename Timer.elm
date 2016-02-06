import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Text
import Signal
import Time
import Color
import Debug


model =
  Signal.foldp update 0 timer


main =
  Signal.map clock model


update time model =
  model + 1


timer : Signal Time.Time
timer =
  Time.every Time.millisecond


clock milliseconds =
  let
     time = toString ((milliseconds / 60) |> round)
  in
    collage 250 250
      [
        filled Color.lightGray (circle 50.0)
        , outlined (solid Color.grey) (circle 50.0)
        , text (Text.fromString time)
        , rotateHand milliseconds
      ]


hand =
  traced (solid Color.darkPurple) (path [(0.0, 25.0), (00.0, 50.0)])


rotateHand time =
  rotate (degrees -(toFloat(round((time/ 60) * 360)))) hand
