import Graphics.Element exposing (..)
import Graphics.Collage exposing (..)
import Html exposing (div, button)
import Text
import Signal
import Time
import Color
import Debug


model =
  Signal.foldp update {seconds = 0, pause = False} everySecond


main =
  Signal.map clock model


update time model =
  {model | seconds = model.seconds + 1}


everySecond : Signal Time.Time
everySecond =
  Time.every Time.second



clock model =
  let
    minute = toString (model.seconds // 60)
    second = toString (model.seconds % 60)
    time = minute ++ ": " ++ second
  in
    collage 250 250
      [
        filled Color.lightGray (circle 50.0)
        , outlined (solid Color.grey) (circle 50.0)
        , text (Text.fromString time)
      ]


hand =
  traced (solid Color.darkPurple) (path [(0.0, 25.0), (00.0, 50.0)])


rotateHand time =
  rotate (degrees -(toFloat(round((time/ 60) * 360)))) hand
