module Helpers (..) where


is13 : Int -> Result String ()
is13 code =
    if code == 13 then
        Ok ()
    else
        Err "not the right key code"
