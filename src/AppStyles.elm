module AppStyles (..) where

import Html.Attributes exposing (..)


show =
  style [("display", "block")]


hide =
  style [("display", "none")]

taskRow =
  style
    [ ("padding", "24px")
    , ("border-bottom", "1px solid #BABABA")
    , ("display", "flex")
    , ("justify-content", "space-between")
    , ("font-size", "24px")
    , ("position", "relative")
    ]

taskControls show =
  style
    [ ("position", "absolute")
    , ("z-index", "1")
    , ("background", "white")
    , ("padding", "0px 8px")
    , if show then ("display", "block") else ("display", "none")
    ]

selectStyles =
  style
    [ ("box-shadow", "0px 2px 5px #BABABA")
    , ("padding", "12px")
    , ("background", "white")
    , ("font-size", "16px")
    ]


applyDisplayFiler filter task =
  if filter == task.stage || filter == "all" then show else hide
