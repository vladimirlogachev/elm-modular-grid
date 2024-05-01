module GridLayout2 exposing (..)

import Element exposing (..)
import Html.Attributes
import Json.Decode



-- SHARED


type alias WindowSize =
    { width : Int
    , height : Int
    }


windowSizeJsDecoder : Json.Decode.Decoder WindowSize
windowSizeJsDecoder =
    Json.Decode.map2 WindowSize
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)


type ScreenClass
    = MobileScreen
    | DesktopScreen


type alias LayoutState =
    { window : WindowSize
    , screenClass : ScreenClass
    , config : LayoutConfig
    , grid :
        { contentWidth : Int
        , columnCount : Int
        , gutter : Int
        , margin : Int
        }
    }


type alias LayoutConfig =
    { mobileScreen :
        { {- Includes grid margins.
             The MobileScreen Figma layouts should use this width first.
             If window width is less than this value, we display horizontal scroll.
          -}
          minGridWidth : Int

        {- Includes grid margins.
           The MobileScreen Figma layouts can use this width for an additional example.
           If not set, then the grid will stretch util the next screen breakpoint
        -}
        , maxGridWidth : Maybe Int
        , columnCount : Int
        , gutter : Int
        , margin : GridMargin
        }
    , desktopScreen :
        { {- Includes grid margins.
             The DesktopScreen Figma layouts should use this width first.
             If window width is equal or greater than this value, the screen class is DesktopScreen.
          -}
          minGridWidth : Int

        {- Includes grid margins.
           The DesktopScreen Figma layouts can use this width for an additional example.
           If not set, then the grid will stretch indefinitely
        -}
        , maxGridWidth : Maybe Int
        , columnCount : Int
        , gutter : Int
        , margin : GridMargin
        }
    }


type GridMargin
    = SameAsGutter
    | GridMargin Int


init : LayoutConfig -> WindowSize -> LayoutState
init config window =
    let
        screenClass : ScreenClass
        screenClass =
            if window.width < config.desktopScreen.minGridWidth then
                MobileScreen

            else
                DesktopScreen
    in
    { window = window
    , screenClass = screenClass
    , config = config
    , grid =
        case screenClass of
            MobileScreen ->
                let
                    gridMargin =
                        case config.mobileScreen.margin of
                            SameAsGutter ->
                                config.mobileScreen.gutter

                            GridMargin margin ->
                                margin

                    maxGridWidth =
                        config.mobileScreen.maxGridWidth
                            |> Maybe.withDefault window.width

                    clampedGridWidth =
                        clamp config.mobileScreen.minGridWidth maxGridWidth window.width

                    clampedContentWidth =
                        clampedGridWidth - (gridMargin * 2)
                in
                { contentWidth = clampedContentWidth
                , columnCount = config.mobileScreen.columnCount
                , gutter = config.mobileScreen.gutter
                , margin = gridMargin
                }

            DesktopScreen ->
                let
                    gridMargin =
                        case config.desktopScreen.margin of
                            SameAsGutter ->
                                config.desktopScreen.gutter

                            GridMargin margin ->
                                margin

                    maxGridWidth =
                        config.desktopScreen.maxGridWidth
                            |> Maybe.withDefault window.width

                    clampedGridWidth =
                        min maxGridWidth window.width

                    clampedContentWidth =
                        clampedGridWidth - (gridMargin * 2)
                in
                { contentWidth = clampedContentWidth
                , columnCount = config.desktopScreen.columnCount
                , gutter = config.desktopScreen.gutter
                , margin = gridMargin
                }
    }


update : LayoutState -> WindowSize -> LayoutState
update { config } window =
    init config window



-- LAYOUT


bodyAttributes : LayoutState -> List (Attribute msg)
bodyAttributes layout =
    [ width (fill |> minimum layout.config.mobileScreen.minGridWidth) ]


layoutOuterAttributes : List (Attribute msg)
layoutOuterAttributes =
    [ width fill ]


layoutInnerAttributes : LayoutState -> List (Attribute msg)
layoutInnerAttributes layout =
    let
        maxWidth =
            case layout.screenClass of
                MobileScreen ->
                    layout.config.mobileScreen.maxGridWidth
                        |> Maybe.withDefault layout.window.width

                DesktopScreen ->
                    layout.config.desktopScreen.maxGridWidth
                        |> Maybe.withDefault layout.window.width
    in
    [ width (fill |> maximum maxWidth)
    , padding layout.grid.margin
    , centerX
    ]



-- PAGE


gridRow :
    LayoutState
    -> List (Element msg)
    -> Element msg
gridRow layout elements =
    row [ width fill, spacing layout.grid.gutter ] elements


gridColumn :
    LayoutState
    -> { widthSteps : Int }
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
gridColumn layout { widthSteps } attrs elements =
    column (widthOfGridSteps layout widthSteps ++ attrs) elements


gridBox :
    LayoutState
    ->
        { widthSteps : Int
        , heightSteps : Int
        }
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
gridBox layout { widthSteps, heightSteps } attrs elements =
    column
        (widthOfGridSteps layout widthSteps
            ++ heightOfGridSteps layout heightSteps
            ++ attrs
        )
        elements


{-| Helper
-}
widthOfGridSteps : LayoutState -> Int -> List (Attribute msg)
widthOfGridSteps layout numberOfSteps =
    let
        baseWidth =
            widthOfGridStepsFloat layout numberOfSteps
    in
    [ -- We must allow elements to grow in order to avoid hairline-thin paddings on the right of each row
      Element.width Element.fill

    -- We must prevent elements of width 1 to grow to all 12.
    -- If we use float value here, we would effectively cancel the "width fill" attribute.
    -- So we use Int to allow to grow just a bit, up to 1 px.
    , Element.htmlAttribute <| Html.Attributes.style "max-width" (String.fromInt (ceiling baseWidth) ++ "px")

    -- This is what actually sets the width. We must use float to maintain constant gutters between elements of different rows
    , Element.htmlAttribute <| Html.Attributes.style "min-width" (String.fromFloat baseWidth ++ "px")
    ]


{-| Helper
-}
heightOfGridSteps : LayoutState -> Int -> List (Attribute msg)
heightOfGridSteps layout numberOfSteps =
    let
        baseHeight =
            widthOfGridStepsFloat layout numberOfSteps
    in
    [ Element.height Element.fill
    , Element.htmlAttribute <| Html.Attributes.style "max-height" (String.fromInt (ceiling baseHeight) ++ "px")
    , Element.htmlAttribute <| Html.Attributes.style "min-height" (String.fromFloat baseHeight ++ "px")
    ]



-- INTERNAL


{-| Implementation detail.
Returns the width of specified number of grid steps (including gutters), in pixels, Float.
-}
widthOfGridStepsFloat : LayoutState -> Int -> Float
widthOfGridStepsFloat layout numberOfSteps =
    let
        columnCount =
            case layout.screenClass of
                MobileScreen ->
                    layout.config.mobileScreen.columnCount

                DesktopScreen ->
                    layout.config.desktopScreen.columnCount

        gutterCountBetween =
            numberOfSteps - 1

        gutterWidth =
            layout.grid.gutter

        stepWidth =
            (toFloat layout.grid.contentWidth - toFloat gutterWidth * (toFloat columnCount - 1))
                / toFloat columnCount
    in
    (stepWidth * toFloat numberOfSteps) + (toFloat gutterWidth * toFloat gutterCountBetween)
