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
import Window exposing (Window, WindowSizeJs)



-- FLAGS


type alias Flags =
    { windowSize : WindowSizeJs }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "windowSize" Window.windowSizeJsDecoder)



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
    ( { window = Window.fromWindowSizeJs flags.windowSize
      }
    , Effect.none
    )


meaninglessDefaultModel : Shared.Model.Model
meaninglessDefaultModel =
    { window = Window.fromWindowSizeJs Window.initWindowSizeJs
    }



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update _ msg model =
    case msg of
        Shared.Msg.GotNewWindowSize newWindowSize ->
            gotNewWindowSize model newWindowSize


gotNewWindowSize : Model -> WindowSizeJs -> ( Model, Effect Msg )
gotNewWindowSize model newWindowSize =
    ( { model | window = Window.fromWindowSizeJs newWindowSize }, Effect.none )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onResize (\width height -> Shared.Msg.GotNewWindowSize { width = width, height = height })
