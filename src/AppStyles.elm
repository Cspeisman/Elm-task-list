module AppStyles (..) where

import Html.Attributes exposing (..)


show =
  style [("display", "block")]


hide =
  style [("display", "none")]

displayTask showTask =
  if showTask then show else hide

taskRow =
  style
    [ ("padding", "20px")
    , ("border-bottom", "1px solid #eee")
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
    , ("font-size", "24px")
    , ("border-radius", "50%")
    , ("width", "65px")
    , ("height", "65px")
    , ("box-shadow", "0px 0px 3px rgba(0, 0, 0, 0.47)")
    ]

plusWrapper =
  style [ ("position", "absolute"), ("right", "8px"), ("bottom", "-16px"), ("z-index", "2") ]

label active =
  style
    [ ("color", "#9c9c9c")
    , ("font-size", "16px")
    , ("padding", "16px")
    , ("letter-spacing", "0.5pt")
    , if active then ("font-weight", "700") else ("font-weight", "400")]

banner isRunning =
  style
    [ if isRunning then ("background", "#5299fd") else ("background", "#585758")
    , ("color", "white")
    ]

taskListControls =
  style [ ("font-size", "16px")
        , ("padding-right", "16px")
        ]

timerStyles isRunning =
  style [ ("padding", "8px 0")
        , ("text-align", "center")
        , ("border-radius", "5px")
        , ("width", "20%")
        , if isRunning then ("background", "#5299fd") else ("background", "#d9d9d9")
        , if isRunning then ("color", "white") else ("color", "#626262")
        ]

bannerControls =
  style
    [ ("color", "white")
    , ("text-align", "center")
    , ("font-size", "36px")
    , ("padding", "24px 0") ]


buttonStyle =
  style
    [ ("background", "#5299fd")
    , ("padding", "8px 24px")
    , ("color", "white")
    , ("font-size", "18px")
    , ("font-weight", "700")
    , ("border-radius", "5px")
    , ("width", "125px")
    ]
