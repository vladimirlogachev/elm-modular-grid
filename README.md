# elm-modular-grid

## Pre-requisites

```sh
npm install
```

## Development

```sh
npm start
```

## How to start using the library, an example based on `elm-land` with `elm-ui`


### Interop.ts

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

### Shared.Model.elm

```elm
type alias Model =
    { layout : GridLayout2.LayoutState
    }

```

### Shared.Msg.elm

```elm
type Msg
    = GotNewWindowSize WindowSize
```


### Shared.elm

```elm
type alias Flags =
    { windowSize : GridLayout2.WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "windowSize" GridLayout2.windowSizeJsDecoder)


layoutConfig : LayoutConfig
layoutConfig =
    { mobileScreen =
        { minGridWidth = 360
        , maxGridWidth = Just 720
        , columnCount = 12
        , gutter = 16
        , margin = SameAsGutter
        }
    , desktopScreen =
        { minGridWidth = 1024
        , maxGridWidth = Just 1440
        , columnCount = 12
        , gutter = 32
        , margin = SameAsGutter
        }
    }

init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    case flagsResult of
        Ok flags ->
            ( { window = GridLayout2.fromWindowSizeJs flags.windowSize } , Effect.none )

        Err _ ->
            Debug.todo ""

update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.GotNewWindowSize newWindowSize ->
            ( { model | window = GridLayout2.fromWindowSizeJs newWindowSize }, Effect.none )

subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
```

### Layout.SingleSectionLayout.elm

```elm
view : Shared.Model -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view shared { content } =
    { title = content.title
    , attributes = content.attributes ++ GridLayout2.bodyAttributes
    , element =
        let
            outerElementAttrs =
                []

            innerElementAttrs =
                []

            outerElement =
                column (GridLayout2.layoutOuterAttributes ++ outerElementAttrs)

            innerElement =
                column (GridLayout2.layoutInnerAttributes shared.window.screenClass ++ innerElementAttrs)
        in
        outerElement [ innerElement [ content.element ] ]
    }
```

### SomePage.elm


```elm
-- TODO:
```
