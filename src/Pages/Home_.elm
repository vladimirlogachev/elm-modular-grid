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
                SmallScreen ->
                    Background.color Color.smallScreenContentBackground

                BigScreen ->
                    Background.color Color.bigScreenContentBackground
            ]
            [ column [ width fill, Background.color Color.white, padding layout.grid.gutter ]
                [ text <| "window.width: " ++ String.fromInt layout.window.width
                , text <| "grid.contentWidth: " ++ String.fromInt layout.grid.contentWidth
                , text <| "grid.columnCount: " ++ String.fromInt layout.grid.columnCount
                , text <| "grid.gutter: " ++ String.fromInt layout.grid.gutter
                , text <| "grid.margin: " ++ String.fromInt layout.grid.margin
                ]
            , gridRow layout
                [ viewBox layout { widthSteps = 11, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                ]
            , gridRow layout
                [ viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 1, heightSteps = 1 }
                ]
            , gridRow layout
                [ viewBox layout { widthSteps = 1, heightSteps = 1 }
                , viewBox layout { widthSteps = 11, heightSteps = 1 }
                ]
            , gridRow layout
                [ viewBox layout { widthSteps = 1, heightSteps = 1 }
                ]
            , gridRow layout
                [ gridColumn layout { widthSteps = 2 } [] [ none ]
                , gridColumn layout
                    { widthSteps = 4 }
                    [ Background.color Color.white, padding layout.grid.gutter ]
                    [ paragraph [ centerX, centerY ]
                        [ text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        , text "A column with width of 4 grid steps and an arbitrary height. "
                        ]
                    ]
                , gridColumn layout { widthSteps = 6 } [] [ none ]
                ]
            ]
    }


viewBox : LayoutState -> { widthSteps : Int, heightSteps : Int } -> Element msg
viewBox layout { widthSteps, heightSteps } =
    gridBox layout
        { widthSteps = widthSteps
        , heightSteps = heightSteps
        }
        [ Background.color Color.white ]
        [ column [ centerX, centerY ] [ text <| String.fromInt widthSteps ++ "x" ++ String.fromInt heightSteps ] ]
