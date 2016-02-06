module InProgress (..) where

import StartApp.Simple as StartApp
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

main =
  view

model string =
  string

update =
  model "foo-updated"

view =
  div
      []
      [text update]
