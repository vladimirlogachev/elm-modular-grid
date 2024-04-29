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
import Json.Decode
import Route exposing (Route)
import Shared.Model
import Shared.Msg
import Window exposing (WindowSize)



-- FLAGS


type alias Flags =
    { windowSize : WindowSize }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "windowSize" Window.windowSizeDecoder)



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


initReady : Flags -> ( Model, Effect Msg )
initReady flags =
    ( { window = flags.windowSize
      , screenClass = Window.classifyScreen flags.windowSize
      }
    , Effect.none
    )


meaninglessDefaultModel : Shared.Model.Model
meaninglessDefaultModel =
    { window = Window.initWindowSize
    , screenClass = Window.classifyScreen Window.initWindowSize
    }



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.GotNewWindowSize newWindowSize ->
            gotNewWindowSize model newWindowSize


gotNewWindowSize : Model -> WindowSize -> ( Model, Effect Msg )
gotNewWindowSize model newWindowSize =
    ( { model | window = newWindowSize, screenClass = Window.classifyScreen newWindowSize }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
