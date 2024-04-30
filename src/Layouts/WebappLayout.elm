port module Layouts.WebappLayout exposing (Model, Msg, Props, layout)

import Color
import Constants
import Effect exposing (Effect)
import Element exposing (..)
import Element.Background as Background
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)
import Window exposing (..)


port urlChanged : () -> Cmd msg


type alias Props =
    {}


layout : Props -> Shared.Model -> Route () -> Layout () Model Msg contentMsg
layout _ shared _ =
    Layout.new
        { init = init
        , update = update
        , view = view shared
        , subscriptions = subscriptions
        }
        |> Layout.withOnUrlChanged UrlChanged



-- MODEL


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init _ =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = UrlChanged { from : Route (), to : Route () }


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UrlChanged _ ->
            ( model, Effect.sendCmd <| urlChanged () )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Shared.Model -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view shared { content } =
    { title = content.title
    , attributes = content.attributes ++ [ width (fill |> minimum Constants.minimalSupportedMobileScreenWidth) ]
    , element =
        let
            outerElement =
                column [ width fill ]

            innerElement =
                column
                    ((case shared.window.screenClass of
                        SmallScreen ->
                            [ width (fill |> minimum Constants.minimalSupportedMobileScreenWidth)
                            , padding Constants.gridMarginSmallScreen
                            , Background.color Color.gridMarginBackground
                            ]

                        BigScreen ->
                            [ width (fill |> maximum Constants.contentWithPaddingsMaxWidthBigScreen)
                            , padding Constants.gridMarginBigScreen
                            , Background.color Color.gridMarginBackground
                            ]
                     )
                        ++ [ centerX ]
                    )
        in
        outerElement [ innerElement [ content.element ] ]
    }
