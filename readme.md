## All aboard the Elm train!

Simply add tasks to a list, and track the time you've spent on each task.

---

### Build instructions
This app should be super simple to get running locally.


#### First
make sure you have elm 0.16 installed

I think the easiest way is by running `npm install -g elm@0.16`

_I am currently in the process of upgrading to 0.17 but for now stick to 0.16_

#### Build
run:
 `make build`

(if this is your first time running the build command you will be prompted to install all the necessary elm modules)

#### Run
Open `index.html` in your browser!

To run electron app version
  run:
    `make app`

---

### File structure
- All of the elm code lives in the `src` directory
- `Main.elm` is the entry point to the application
- Each "module" has its own directory with 3 files in it
  - Types (includes all Type definitions and Type Unions)
  - View (responsible for display logic)
  - State (all functions that influence the module's state)

  _this file structure fits well with The Elm Architecture while keeping files from getting too bloated_

There is also an `AppStyles.elm`file which include methods for inlining styles. However, styles are completely all over the place and there is a plan to [migrate it all to elm-css](https://github.com/Cspeisman/Elm-task-list/issues/2)

`Helpers.elm` include a few useful helper methods used amongst modules but don't really have their own home to live in
