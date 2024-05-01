# elm-modular-grid

Responsive modular grid layouts for Elm.

Designed for `elm-ui` and `elm-land`, but can be useful with `elm-css` or even pure CSS too.

## What is a modular grid?

A modular grid is a well-known pattern in design which helps to establish a visual rhythm and produce layouts designs quickly and in a controlled way. A simple explanation is given [Design Trampoline. Module 5: Grid](https://designtrampoline.org/module/grid/grid/), and more info can be found on the web.

In the code, we refer to the following elements of grid:

![Grid elements](https://github.com/vladimirlogachev/elm-modular-grid/blob/main/docs/grid-elements.svg?raw=true)

The full potential of modular grid design will be realized if the layouts are designed in Figma or another similar tool before coding. But this is optional.

## Features

- Responsive grid columns (step width is variable, columns can grow, but gutter and minimal margin are fixed).
- Allows to establish a vertical rhythm using column width, and maintain proportions of the grid elements on different screen sizes.

## Example usage with `elm-land` and `elm-ui`

### `elm.json`

```sh
elm install elm/browser
```

### `interop.ts`

```ts
export const flags = ({ env }) => {
  return {
    windowSize: {
      height: window.innerHeight,
      width: window.innerWidth,
    },
  };
};
```

### `Shared/Model.elm`

```elm
import GridLayout2

type alias Model =
    { layout : GridLayout2.LayoutState
    }

```

### `Shared/Msg.elm`

```elm
import GridLayout2

type Msg
    = GotNewWindowSize GridLayout2.WindowSize
```

### `Shared.elm`

```elm
import GridLayout2

type alias Flags =
    { windowSize : GridLayout2.WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "windowSize" GridLayout2.windowSizeDecoder)


layoutConfig : GridLayout2.LayoutConfig
layoutConfig =
    { mobileScreen =
        { minGridWidth = 360
        , maxGridWidth = Just 720
        , columnCount = 12
        , gutter = 16
        , margin = GridLayout2.SameAsGutter
        }
    , desktopScreen =
        { minGridWidth = 1024
        , maxGridWidth = Just 1440
        , columnCount = 12
        , gutter = 32
        , margin = GridLayout2.SameAsGutter
        }
    }

init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    case flagsResult of
        Ok flags ->
            ( { window = GridLayout2.init layoutConfig flags.windowSize } , Effect.none )

        Err _ ->
            Debug.todo ""

update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.GotNewWindowSize newWindowSize ->
            ( { model | window = GridLayout2.update model.layout newWindowSize }, Effect.none )

subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
```

### `Layouts/SingleSectionLayout.elm`

```elm
import GridLayout2

view : Shared.Model -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view shared { content } =
    { title = content.title
    , attributes = content.attributes ++ GridLayout2.bodyAttributes shared.layout
    , element =
        let
            outerElementAttrs : List (Attribute msg)
            outerElementAttrs =
                []

            innerElementAttrs : List (Attribute msg)
            innerElementAttrs =
                [ Background.color Color.gridMarginBackground ]

            outerElement : List (Element msg) -> Element msg
            outerElement =
                column (GridLayout2.layoutOuterAttributes ++ outerElementAttrs)

            innerElement : List (Element msg) -> Element msg
            innerElement =
                column (GridLayout2.layoutInnerAttributes shared.layout ++ innerElementAttrs)
        in
        outerElement [ innerElement [ content.element ] ]
    }
```

### `Pages/Home_.elm`

```elm
import GridLayout2 exposing (..)

view : Shared.Model -> View msg
view { layout } =
    { title = "elm-modular-grid"
    , attributes = [ Background.color Color.bodyBackground ]
    , element =
        column
            [ width fill
            , spacing layout.grid.gutter
            , case layout.screenClass of
                MobileScreen ->
                    Background.color Color.mobileScreenContentBackground

                DesktopScreen ->
                    Background.color Color.desktopScreenContentBackground
            ]
            [ gridRow layout
                [ gridColumn layout
                    { widthSteps = 4 }
                    [ Background.color Color.white, padding layout.grid.gutter, alignTop ]
                    [ paragraph [] [ text "A column with width of 4 grid steps and an arbitrary height. " ]
                    ]
                , gridBox
                    layout
                    { widthSteps = 2
                    , heightSteps = 4
                    }
                    [ Background.color Color.white, padding layout.grid.gutter ]
                    [ paragraph [] [ text "A box with width of 2 modular grid steps and height of 4 steps, including gutters" ] ]
                , gridBox
                    layout
                    { widthSteps = 6
                    , heightSteps = 3
                    }
                    [ Background.color Color.white ]
                    [ column [ centerX, centerY ] [ text "6 x 3 steps" ] ]
                ]
            ]
    }
```

### Result

![Result](https://github.com/vladimirlogachev/elm-modular-grid/blob/main/docs/example-usage-result.jpg?raw=true)

## Package Development

- Build and preview docs
  - `npm run build -- --docs docs.json`
  - Open https://elm-doc-preview.netlify.app
  - Open Files -> `README.md` and `docs.json` -> review... -> Close Preview
