module Pages.Home_ exposing (Model, Msg, page)

import Color
import Effect
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import GridLayout2 exposing (..)
import Layouts
import Page exposing (Page)
import Route exposing (Route)
import Shared
import TextStyle
import View exposing (View)
import VitePluginHelper


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



-- DATA


pageTitle : String
pageTitle =
    "Elm modular grid"


paragraphTitle : String
paragraphTitle =
    "Module and grid explained"


paragraphText : String
paragraphText =
    """
A modular grid is a tool that helps to make a layout.
It consists of simple geometric shapes – modules of the same size, located in a certain sequence.
The grid allows you to split the layout into equal cells  – modules and adjust all 
the indents and sizes of each object so that they are a multiple of the module size.
"""


type alias Image =
    { url : String
    , description : String
    , placeholderColor : Color
    , sourceSize : { width : Int, height : Int }
    }


importantImage : Image
importantImage =
    { url = VitePluginHelper.asset "/assets/images/important-image.svg"
    , description = "Important image"
    , placeholderColor = rgb255 0xB2 0xEB 0xF2
    , sourceSize = { width = 600, height = 400 }
    }


type alias Block =
    { title : String
    , description : String
    , color : Color
    }


block1 : Block
block1 =
    { title = "Block 1", description = "Some description", color = rgb255 0xB2 0xEB 0xF2 }


block2 : Block
block2 =
    { title = "Block 2", description = "Some description", color = rgb255 0xBB 0xDE 0xFB }


block3 : Block
block3 =
    { title = "Block 3", description = "Some description", color = rgb255 0xFF 0xE0 0xB2 }


block4 : Block
block4 =
    { title = "Block 4", description = "Some description", color = rgb255 0xB2 0xEB 0xF2 }



-- VIEW


view : Shared.Model -> View msg
view { layout } =
    { title = "elm-modular-grid"
    , attributes = []
    , element =
        case layout.screenClass of
            MobileScreen ->
                viewMobile layout

            DesktopScreen ->
                viewDesktop layout
    }


viewMobile : LayoutState -> Element msg
viewMobile layout =
    column
        [ width fill
        , spacing layout.grid.gutter
        ]
        [ row [ width fill ] [ paragraph (width fill :: TextStyle.headerMobile) [ text pageTitle ] ]
        , image
            (scaleProportionallyToWidthOfGridSteps layout
                { originalWidth = importantImage.sourceSize.width
                , originalHeight = importantImage.sourceSize.height
                , widthSteps = 6
                }
            )
            { src = importantImage.url, description = importantImage.description }
        , column [ spacing layout.grid.gutter ]
            [ paragraph TextStyle.subheaderMobile [ text paragraphTitle ]
            , paragraph [] [ text paragraphText ]
            ]
        , gridRow layout
            [ viewBlockMobile layout { widthSteps = 3, heightSteps = 4 } block1
            , viewBlockMobile layout { widthSteps = 3, heightSteps = 4 } block2
            ]
        , gridRow layout
            [ viewBlockMobile layout { widthSteps = 4, heightSteps = 4 } block3
            , viewBlockMobile layout { widthSteps = 2, heightSteps = 4 } block4
            ]
        ]


viewBlockMobile : LayoutState -> { widthSteps : Int, heightSteps : Int } -> Block -> Element msg
viewBlockMobile layout { widthSteps, heightSteps } block =
    gridBox
        layout
        { widthSteps = widthSteps
        , heightSteps = heightSteps
        }
        [ Background.color block.color
        , Font.color Color.white
        , padding layout.grid.gutter
        ]
        [ paragraph TextStyle.subheaderMobile [ text block.title ]
        , paragraph [ alignBottom, width fill, Font.alignRight ] [ text block.description ]
        ]


viewDesktop : LayoutState -> Element msg
viewDesktop layout =
    column
        [ width fill
        , spacing layout.grid.gutter
        ]
        [ row [ width fill ]
            [ paragraph ([ width fill, padding layout.grid.gutter ] ++ TextStyle.headerDesktop) [ text pageTitle ] ]
        , gridRow layout
            [ image
                (scaleProportionallyToWidthOfGridSteps layout
                    { originalWidth = importantImage.sourceSize.width
                    , originalHeight = importantImage.sourceSize.height
                    , widthSteps = 6
                    }
                    ++ [ alignTop ]
                )
                { src = importantImage.url, description = importantImage.description }
            , gridColumn layout
                { widthSteps = 6 }
                [ spacing layout.grid.gutter, alignTop ]
                [ paragraph TextStyle.subheaderDesktop [ text paragraphTitle ]
                , paragraph [] [ text paragraphText ]
                ]
            ]
        , gridRow layout
            [ viewBlockDesktop layout { widthSteps = 4, heightSteps = 5 } block1
            , viewBlockDesktop layout { widthSteps = 4, heightSteps = 5 } block2
            , gridBox layout
                { widthSteps = 4, heightSteps = 5 }
                [ spacing layout.grid.gutter ]
                [ viewBlockDesktop layout { widthSteps = 4, heightSteps = 3 } block3
                , viewBlockDesktop layout { widthSteps = 4, heightSteps = 2 } block4
                ]
            ]
        ]


viewBlockDesktop : LayoutState -> { widthSteps : Int, heightSteps : Int } -> Block -> Element msg
viewBlockDesktop layout { widthSteps, heightSteps } block =
    gridBox
        layout
        { widthSteps = widthSteps
        , heightSteps = heightSteps
        }
        [ Background.color block.color
        , Font.color Color.white
        , padding layout.grid.gutter
        ]
        [ paragraph TextStyle.subheaderDesktop [ text block.title ]
        , paragraph [ alignBottom, width fill, Font.alignRight ] [ text block.description ]
        ]
