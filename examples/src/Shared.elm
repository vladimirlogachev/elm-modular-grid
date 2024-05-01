module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Browser.Events
import Effect exposing (Effect)
import GridLayout2
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    { windowSize : GridLayout2.WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "windowSize" GridLayout2.windowSizeDecoder)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult _ =
    case flagsResult of
        Ok flags ->
            initReady flags

        Err _ ->
            ( meaninglessDefaultModel
            , Effect.none
            )


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


initReady : Flags -> ( Model, Effect Msg )
initReady flags =
    ( { layout = GridLayout2.init layoutConfig flags.windowSize
      }
    , Effect.none
    )


meaninglessDefaultModel : Shared.Model.Model
meaninglessDefaultModel =
    { layout = GridLayout2.init layoutConfig { width = 1024, height = 768 }
    }



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.GotNewWindowSize newWindowSize ->
            gotNewWindowSize model newWindowSize


gotNewWindowSize : Model -> GridLayout2.WindowSize -> ( Model, Effect Msg )
gotNewWindowSize model newWindowSize =
    ( { model | layout = GridLayout2.update model.layout newWindowSize }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions _ _ =
    Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
