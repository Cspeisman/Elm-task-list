import StartApp.Simple as StartApp

import Todo exposing (model, update, view)


main =
    StartApp.start { model = model, view = view, update = update }
