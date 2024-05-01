module Pages.Home_ exposing (Model, Msg, page)

import Color
import Effect
import Element exposing (..)
import Element.Background as Background
import GridLayout2 exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


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
        |> Page.withLayout (always <| Layouts.SingleSectionLayout {})


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
