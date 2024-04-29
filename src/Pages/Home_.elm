module Pages.Home_ exposing (Model, Msg, page)

import Color
import Effect
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)
import Window exposing (ScreenClass(..))


type alias Model =
    ()


type alias Msg =
    ()


page : Shared.Model -> Route () -> Page Model Msg
page shared _ =
    Page.new
        { init = always ( (), Effect.none )
        , update = \_ _ -> ( (), Effect.none )
        , subscriptions = always Sub.none
        , view = always <| view shared
        }
        |> Page.withLayout (always <| Layouts.WebappLayout {})


view : Shared.Model -> View msg
view shared =
    { title = "elm-modular-grid"
    , attributes = [ Font.color Color.white, Background.color Color.grey1 ]
    , element =
        column [ spacing 20 ]
            [ text "elm-modular-grid"
            , text
                ("w: "
                    ++ String.fromInt shared.window.width
                    ++ ", h: "
                    ++ String.fromInt shared.window.height
                )
            ]
    }
