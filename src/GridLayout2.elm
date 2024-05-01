module GridLayout2 exposing
    ( WindowSize, windowSizeDecoder, ScreenClass(..), LayoutState, LayoutConfig, GridMargin(..), init, update
    , bodyAttributes, layoutOuterAttributes, layoutInnerAttributes
    , gridRow, gridColumn, gridBox, widthOfGridSteps, heightOfGridSteps
    , widthOfGridStepsFloat
    )

{-| `GridLayout2` stands for 2 screen classes: Mobile and Desktop.


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


{-| A window size object coming from Flags, and cunstructed from the `Browser.Events.onResize` event.
-}
type alias WindowSize =
    { width : Int
    , height : Int
    }


{-| A decoder for the `WindowSize` type, for Flags.
-}
windowSizeDecoder : Json.Decode.Decoder WindowSize
windowSizeDecoder =
    Json.Decode.map2 WindowSize
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)


{-| A screen class. Similar to `Element.DeviceClass` from `elm-ui`,
but narrowed down to support only 2 devices both in grid layout and in the application code.
Names differe from `Element.DeviceClass` to avoid import conflicts
when importing everything from both `Element` and `GridLayout2`.
-}
type ScreenClass
    = MobileScreen
    | DesktopScreen


{-| Layout state. A value of this type contains everything needed to render a layout or any grid-aware element.
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


{-| Layout configuration. Needs to be passed in the `init` function once per app.
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


{-| An option for grid margins.

  - `SameAsGutter` – the minimal modular grid margin will be the same as the gutter.
  - `GridMargin` – allows to specify the minimal modular grid margin manually.

-}
type GridMargin
    = SameAsGutter
    | GridMargin Int


{-| Initializes the layout state, which then needs to be stored in some sort of `Shared.Model`.
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


{-| Updates the layout state. The previous state is passed from the `Shared.Model`.
-}
update : LayoutState -> WindowSize -> LayoutState
update { config } window =
    init config window



-- LAYOUT


{-| A helper to build the application `Layout`. See Readme for example usage.
-}
bodyAttributes : LayoutState -> List (Attribute msg)
bodyAttributes layout =
    [ width (fill |> minimum layout.config.mobileScreen.minGridWidth) ]


{-| A helper to build the application `Layout`. See Readme for example usage.
-}
layoutOuterAttributes : List (Attribute msg)
layoutOuterAttributes =
    [ width fill ]


{-| A helper to build the application `Layout`. See Readme for example usage.
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


{-| A helper to be used in application pages. See Readme for example usage.
-}
gridRow :
    LayoutState
    -> List (Element msg)
    -> Element msg
gridRow layout elements =
    row [ width fill, spacing layout.grid.gutter ] elements


{-| A helper to be used in application pages.
Sets container width in terms of modular grid steps, and allows arbitrary height.
See Readme for example usage.
-}
gridColumn :
    LayoutState
    -> { widthSteps : Int }
    -> List (Attribute msg)
    -> List (Element msg)
    -> Element msg
gridColumn layout { widthSteps } attrs elements =
    column (widthOfGridSteps layout widthSteps ++ attrs) elements


{-| A helper to be used in application pages.
Sets both container width and height in terms of modular grid steps,
which allows the element design to have not only predictable width, but also predictable height.
See Readme for example usage.
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


{-| A helper to be used in application pages with `elm-ui` whenever `gridColumn` and `gridBox` don't math your needs.
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


{-| A helper to be used in application pages with `elm-ui` whenever `gridColumn` and `gridBox` don't math your needs.
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
