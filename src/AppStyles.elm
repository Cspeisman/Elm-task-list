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
    , ("color", "#3a3a3a")
    , ("width", "100%")
    ]

taskControls show =
  style
    [ ("position", "absolute")
    , ("z-index", "1")
    , ("background", "white")
    , ("color", "#41aac1")
    , ("padding", "0px 8px")
    , if show then ("display", "block") else ("display", "none")
    ]

selectStyles =
  style
    [ ("box-shadow", "0px 2px 5px #BABABA")
    , ("padding", "12px")
    , ("background", "white")
    , ("font-size", "16px")
    , ("color", "#3a3a3a")
    ]

plusButton =
  style
    [ ("background-color", "#006e73")
    , ("color", "white")
    , ("padding", "21px 26px")
    , ("padding-top", "18px")
    , ("font-size", "24px")
    , ("border-radius", "50%")
    ]

label =
  style [ ("color", "#11777d"), ("font-size", "16px")]

banner =
  style
    [ ("background", "linear-gradient(135deg, #72bffa, #48d6a8)")
    , ("color", "white")
    ]


applyDisplayFiler filter task =
  if filter == task.stage || filter == "all" then show else hide
