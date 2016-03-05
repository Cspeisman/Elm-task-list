module AppStyles (..) where

import Html.Attributes exposing (..)


show =
  style [("display", "block")]


hide =
  style [("display", "none")]


applyDisplayFiler filter task =
  if filter == task.stage || filter == "all" then show else hide
