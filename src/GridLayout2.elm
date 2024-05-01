module GridLayout2 exposing
    ( WindowSize, windowSizeDecoder, ScreenClass(..), LayoutState, LayoutConfig, GridMargin(..), init, update
    , bodyAttributes, layoutOuterAttributes, layoutInnerAttributes
    , gridRow, gridColumn, gridBox, widthOfGridSteps, heightOfGridSteps
    , widthOfGridStepsFloat
    )

{-| test


# Shared

@docs WindowSize, windowSizeDecoder, ScreenClass, LayoutState, LayoutConfig, GridMargin, init, update


# Layout

@docs bodyAttributes, layoutOuterAttributes, layoutInnerAttributes


# Page

@docs gridRow, gridColumn, gridBox, widthOfGridSteps, heightOfGridSteps


# Internal

@docs widthOfGridStepsFloat

-}

import Element exposing (..)
import Html.Attributes
import Json.Decode



-- SHARED


{-| TODO:
-}
type alias WindowSize =
    { width : Int
    , height : Int
    }


{-| TODO:
-}
windowSizeDecoder : Json.Decode.Decoder WindowSize
windowSizeDecoder =
    Json.Decode.map2 WindowSize
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)


{-| TODO:
-}
type ScreenClass
    = MobileScreen
    | DesktopScreen


{-| TODO:
-}
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


{-| TODO:
-}
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


{-| TODO:
-}
type GridMargin
    = SameAsGutter
    | GridMargin Int


{-| TODO:
-}
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
                    gridMargin : Int
                    gridMargin =
                        case config.mobileScreen.margin of
                            SameAsGutter ->
                                config.mobileScreen.gutter

                            GridMargin margin ->
                                margin

                    maxGridWidth : Int
                    maxGridWidth =
                        config.mobileScreen.maxGridWidth
                            |> Maybe.withDefault window.width

                    clampedGridWidth : Int
                    clampedGridWidth =
                        clamp config.mobileScreen.minGridWidth maxGridWidth window.width

                    clampedContentWidth : Int
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
                    gridMargin : Int
                    gridMargin =
                        case config.desktopScreen.margin of
                            SameAsGutter ->
                                config.desktopScreen.gutter

                            GridMargin margin ->
                                margin

                    maxGridWidth : Int
                    maxGridWidth =
                        config.desktopScreen.maxGridWidth
                            |> Maybe.withDefault window.width

                    clampedGridWidth : Int
                    clampedGridWidth =
                        min maxGridWidth window.width

                    clampedContentWidth : Int
                    clampedContentWidth =
                        clampedGridWidth - (gridMargin * 2)
                in
                { contentWidth = clampedContentWidth
                , columnCount = config.desktopScreen.columnCount
                , gutter = config.desktopScreen.gutter
                , margin = gridMargin
                }
    }


{-| TODO:
-}
update : LayoutState -> WindowSize -> LayoutState
update { config } window =
    init config window



-- LAYOUT


{-| TODO:
-}
bodyAttributes : LayoutState -> List (Attribute msg)
bodyAttributes layout =
    [ width (fill |> minimum layout.config.mobileScreen.minGridWidth) ]


{-| TODO:
-}
layoutOuterAttributes : List (Attribute msg)
layoutOuterAttributes =
    [ width fill ]


{-| TODO:
-}
layoutInnerAttributes : LayoutState -> List (Attribute msg)
layoutInnerAttributes layout =
    let
        maxWidth : Int
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


{-| TODO:
-}
gridRow :
    LayoutState
    -> List (Element msg)
    -> Element msg
gridRow layout elements =
    row [ width fill, spacing layout.grid.gutter ] elements


{-| TODO:
-}
gridColumn :
    LayoutState
    -> { widthSteps : Int }
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
gridColumn layout { widthSteps } attrs elements =
    column (widthOfGridSteps layout widthSteps ++ attrs) elements


{-| TODO:
-}
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


{-| TODO:
-}
widthOfGridSteps : LayoutState -> Int -> List (Attribute msg)
widthOfGridSteps layout numberOfSteps =
    let
        baseWidth : Float
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


{-| TODO:
-}
heightOfGridSteps : LayoutState -> Int -> List (Attribute msg)
heightOfGridSteps layout numberOfSteps =
    let
        baseHeight : Float
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
        columnCount : Int
        columnCount =
            case layout.screenClass of
                MobileScreen ->
                    layout.config.mobileScreen.columnCount

                DesktopScreen ->
                    layout.config.desktopScreen.columnCount

        gutterCountBetween : Int
        gutterCountBetween =
            numberOfSteps - 1

        gutterWidth : Int
        gutterWidth =
            layout.grid.gutter

        stepWidth : Float
        stepWidth =
            (toFloat layout.grid.contentWidth - toFloat gutterWidth * (toFloat columnCount - 1))
                / toFloat columnCount
    in
    (stepWidth * toFloat numberOfSteps) + (toFloat gutterWidth * toFloat gutterCountBetween)
