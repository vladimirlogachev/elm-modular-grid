module Pages.Home_ exposing (Model, Msg, page)

import Color
import Effect
import Element exposing (..)
import Element.Background as Background
import Html.Attributes
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)
import Window exposing (ScreenClass(..), heightOfGridSteps, widthOfGridSteps)


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
    , attributes = [ Background.color Color.bodyBackground ]
    , element =
        column
            [ width fill
            , spacing (Window.spacingEqualToGridGutter shared.window.screenClass)
            , case shared.window.screenClass of
                SmallScreen ->
                    Background.color Color.smallScreenContentBackground

                BigScreen ->
                    Background.color Color.bigScreenContentBackground
            ]
            [ column
                [ spacing (Window.spacingEqualToGridGutter shared.window.screenClass)
                , width fill
                , Background.color Color.white
                , padding (Window.spacingEqualToGridGutter shared.window.screenClass)
                ]
                [ text "elm-modular-grid"
                , text
                    ("w: "
                        ++ String.fromInt shared.window.width
                        ++ ", h: "
                        ++ String.fromInt shared.window.height
                    )
                ]

            --  width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass)
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 3
                , viewBox2 shared 3
                , viewBox2 shared 3
                , viewBox2 shared 3
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 1
                , viewBox2 shared 5
                , viewBox2 shared 1
                , viewBox2 shared 5
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 2
                , viewBox2 shared 4
                , viewBox2 shared 2
                , viewBox2 shared 4
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 9
                , viewBox2 shared 3
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 11
                , viewBox2 shared 1
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                , viewBox2 shared 1
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 1
                , viewBox2 shared 11
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 1
                ]
            , row [ width fill, spacing (Window.spacingEqualToGridGutter shared.window.screenClass) ]
                [ viewBox2 shared 4
                , viewBox2 shared 4
                , viewBox2 shared 4
                ]
            ]
    }


viewBox2 : Shared.Model -> Int -> Element msg
viewBox2 shared num =
    column
        ([ Background.color Color.white
         , htmlAttribute <| Html.Attributes.style "color" "red"
         ]
            ++ heightOfGridSteps shared.window (min num 3)
            ++ widthOfGridSteps shared.window num
        )
        [ column [ centerX, centerY ] [ text <| String.fromInt num ] ]
