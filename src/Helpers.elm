module Helpers (..) where


fromJust : Maybe a -> a
fromJust x = case x of
    Just y -> y
    Nothing -> Debug.crash "error: fromJust Nothing"


is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()
    else
        Err "not the right key code"
