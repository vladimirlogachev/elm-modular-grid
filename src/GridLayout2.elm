module GridLayout2 exposing
    ( ScreenClass(..)
    , LayoutState, LayoutConfig, WrappedConfig, GridMargin(..), WindowSize, windowSizeDecoder, init, update
    , bodyAttributes, layoutOuterAttributes, layoutInnerAttributes, section
    , gridRow, gridColumn, gridBox, widthOfGridSteps, widthOfGridStepsFloat, heightOfGridSteps, scaleProportionallyToWidthOfGridSteps, scaleProportionallyToWidthOfGridStepsFloat
    )

{-| `GridLayout2` stands for 2 screen classes: Mobile and Desktop.

@docs ScreenClass


# Shared

@docs LayoutState, LayoutConfig, WrappedConfig, GridMargin, WindowSize, windowSizeDecoder, init, update


# Layout

@docs bodyAttributes, layoutOuterAttributes, layoutInnerAttributes, section


# Page

@docs gridRow, gridColumn, gridBox, widthOfGridSteps, widthOfGridStepsFloat, heightOfGridSteps, scaleProportionallyToWidthOfGridSteps, scaleProportionallyToWidthOfGridStepsFloat

-}

import Element exposing (..)
import Html.Attributes
import Json.Decode


{-| A screen class. Similar to `Element.DeviceClass` from `elm-ui`,
but narrowed down to support only 2 devices both in grid layout and in the application code.
Names differ from `Element.DeviceClass` to avoid import conflicts
when importing everything from both `Element` and `GridLayout2`.
-}
type ScreenClass
    = MobileScreen
    | DesktopScreen


{-| Layout state. A value of this type contains everything needed to render a layout or any grid-aware element.

  - `window` – the current window size.
  - `screenClass` – the current screen class.
  - `config` – the layout configuration. Not to be changed during the app lifecycle, or even accessed directly.
  - `grid` – the current grid settings, calculated based on the window size and the screen class. Use them anywhere in the app.

-}
type alias LayoutState =
    { window : WindowSize
    , screenClass : ScreenClass
    , config : WrappedConfig
    , grid :
        { contentWidth : Int
        , columnCount : Int
        , gutter : Int
        , margin : Int
        }
    }


{-| Layout configuration. Needs to be passed in the `init` function once per app.

  - `mobileScreen.minGridWidth` – Includes grid margins.
    The MobileScreen Figma layouts should use this width first.
    If the window width is less than this value, we display a horizontal scroll.
  - `mobileScreen.maxGridWidth` – Includes grid margins.
    The MobileScreen Figma layouts can use this width as an additional example.
    If not set, then the grid will stretch until the next screen breakpoint.
  - `desktopScreen.minGridWidth` – Includes grid margins.
    The DesktopScreen Figma layouts should use this width first.
    If the window width is equal to or greater than this value, the screen class is DesktopScreen.
  - `desktopScreen.maxGridWidth` – Includes grid margins.
    The DesktopScreen Figma layouts can use this width as an additional example.
    If not set, then the grid will stretch indefinitely.
  - `columnCount` – The number of columns in the grid.
  - `gutter` – The width of the gutter between columns, in pixels.
  - `margin` – The minimal modular grid margin. Can be `SameAsGutter` or `GridMargin` with a specific value, in pixels.

-}
type alias LayoutConfig =
    { mobileScreen :
        { minGridWidth : Int
        , maxGridWidth : Maybe Int
        , columnCount : Int
        , gutter : Int
        , margin : GridMargin
        }
    , desktopScreen :
        { minGridWidth : Int
        , maxGridWidth : Maybe Int
        , columnCount : Int
        , gutter : Int
        , margin : GridMargin
        }
    }


{-| `LayoutConfig` is not meant to be accessed from the client code, so it's wrapped in this type to prevent direct access.
-}
type WrappedConfig
    = WrappedConfig LayoutConfig


{-| A helper to access the wrapped config.
-}
accessConfig : WrappedConfig -> LayoutConfig
accessConfig (WrappedConfig config) =
    config


{-| An option for grid margins.

  - `SameAsGutter` – the minimal modular grid margin will be the same as the gutter.
  - `GridMargin` – allows to specify the minimal modular grid margin manually.

-}
type GridMargin
    = SameAsGutter
    | GridMargin Int


{-| A window size object coming from Flags and constructed from the `Browser.Events.onResize` event.
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
    , config = WrappedConfig config
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
    init (accessConfig config) window


{-| A helper to build the application `Layout`. See Readme for example usage.
-}
bodyAttributes : LayoutState -> List (Attribute msg)
bodyAttributes layout =
    [ width (fill |> minimum (accessConfig layout.config).mobileScreen.minGridWidth) ]


{-| A helper to build the application `Layout`. See Readme for example usage.
-}
layoutOuterAttributes : List (Attribute msg)
layoutOuterAttributes =
    [ width fill ]


{-| A helper to build the application `Layout`. See Readme for example usage.
-}
layoutInnerAttributes : LayoutState -> List (Attribute msg)
layoutInnerAttributes layout =
    [ width (fill |> maximum (innerElementMaxWidth layout))
    , padding layout.grid.margin
    , centerX
    ]


{-| Implementation detail.
-}
innerElementMaxWidth : LayoutState -> Int
innerElementMaxWidth layout =
    case layout.screenClass of
        MobileScreen ->
            (accessConfig layout.config).mobileScreen.maxGridWidth
                |> Maybe.withDefault layout.window.width

        DesktopScreen ->
            (accessConfig layout.config).desktopScreen.maxGridWidth
                |> Maybe.withDefault layout.window.width


{-| Use this helper to build pages containing multiple sections, each with full-width background.
The `content` will obey the modular grid, while the `outerElementAttrs`
allows you to set the background color, gradient, or image.

Important note:

  - The `section` inner element only sets `left` and `right` grid margins.
    The `top` and `bottom` are unset for versatility.
  - The `content` only needs to have the `top` and `bottom` paddings set,
    e.g.: `paddingEach { top = layout.grid.margin, bottom = layout.grid.margin, right = 0, left = 0 }`
    or `paddingXY 0 20`.

-}
section : LayoutState -> { outerElementAttrs : List (Attribute msg) } -> Element msg -> Element msg
section layout { outerElementAttrs } content =
    let
        innerElementAttrs : List (Attribute msg)
        innerElementAttrs =
            []

        outerElement : List (Element msg) -> Element msg
        outerElement =
            column (layoutOuterAttributes ++ outerElementAttrs)

        sectionInnerAttributes : List (Attribute msg)
        sectionInnerAttributes =
            [ width (fill |> maximum (innerElementMaxWidth layout))
            , paddingXY layout.grid.margin 0
            , centerX
            ]

        innerElement : List (Element msg) -> Element msg
        innerElement =
            column (sectionInnerAttributes ++ innerElementAttrs)
    in
    outerElement [ innerElement [ content ] ]


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
    {- Note: the elements are wrapped twice because if we don't,
       and if client attrs set inline style as Html.Attributes.attribute,
       the inline style will be overriden and the layout will break.
    -}
    column (alignTop :: height fill :: widthOfGridSteps layout widthSteps)
        [ column (width fill :: attrs) elements ]


{-| A helper to be used in application pages.
Sets both container width and height in terms of modular grid steps,
which allows the element design to have not only predictable width but also predictable height.
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
    {- Note: the elements are wrapped twice because if we don't,
       and if client attrs set inline style as Html.Attributes.attribute,
       the inline style will be overriden and the layout will break.
    -}
    column (alignTop :: widthOfGridSteps layout widthSteps ++ heightOfGridSteps layout heightSteps)
        [ column ([ width fill, height fill ] ++ attrs) elements ]


{-| A helper to be used in application pages with `elm-ui` whenever `gridColumn` and `gridBox` don't match your needs.
-}
widthOfGridSteps : LayoutState -> Int -> List (Attribute msg)
widthOfGridSteps layout numberOfSteps =
    let
        calculatedWidth : Float
        calculatedWidth =
            widthOfGridStepsFloat layout numberOfSteps
    in
    [ -- We must allow elements to grow in order to avoid hairline-thin paddings on the right of each row
      Element.width Element.fill

    -- We must prevent elements of width 1 to grow to all 12.
    -- If we use float value here, we would effectively cancel the "width fill" attribute.
    -- So we use Int to allow to grow just a bit, up to 1 px.
    , Element.htmlAttribute <| Html.Attributes.style "max-width" (String.fromInt (ceiling calculatedWidth) ++ "px")

    -- This is what actually sets the width. We must use float to maintain constant gutters between elements of different rows
    , Element.htmlAttribute <| Html.Attributes.style "min-width" (String.fromFloat calculatedWidth ++ "px")
    ]


{-| An implementation detail, but can be used directly in applications without `elm-ui`.
Returns the width of a specified number of grid steps (including gutters), in pixels, Float.
-}
widthOfGridStepsFloat : LayoutState -> Int -> Float
widthOfGridStepsFloat layout numberOfSteps =
    let
        gutterCountBetween : Int
        gutterCountBetween =
            numberOfSteps - 1

        stepWidth : Float
        stepWidth =
            (toFloat layout.grid.contentWidth - toFloat layout.grid.gutter * (toFloat layout.grid.columnCount - 1))
                / toFloat layout.grid.columnCount
    in
    (stepWidth * toFloat numberOfSteps) + (toFloat layout.grid.gutter * toFloat gutterCountBetween)


{-| A helper to be used in application pages with `elm-ui` whenever `gridColumn` and `gridBox` don't match your needs.
-}
heightOfGridSteps : LayoutState -> Int -> List (Attribute msg)
heightOfGridSteps layout numberOfSteps =
    let
        calculatedHeight : Float
        calculatedHeight =
            widthOfGridStepsFloat layout numberOfSteps
    in
    [ Element.height Element.fill
    , Element.htmlAttribute <| Html.Attributes.style "max-height" (String.fromFloat calculatedHeight ++ "px")
    , Element.htmlAttribute <| Html.Attributes.style "min-height" (String.fromFloat calculatedHeight ++ "px")
    ]


{-| A to scale an element to a specified width of steps, maintaining the original proportions (e.g. of an image which you want never to be cropped).
-}
scaleProportionallyToWidthOfGridSteps :
    LayoutState
    ->
        { originalWidth : Int
        , originalHeight : Int
        , widthSteps : Int
        }
    -> List (Attribute msg)
scaleProportionallyToWidthOfGridSteps layout params =
    let
        { width, height } =
            scaleProportionallyToWidthOfGridStepsFloat layout params
    in
    widthOfGridSteps layout params.widthSteps
        ++ [ Element.htmlAttribute <| Html.Attributes.style "max-width" (String.fromFloat width ++ "px")
           , Element.htmlAttribute <| Html.Attributes.style "min-width" (String.fromFloat width ++ "px")
           , Element.htmlAttribute <| Html.Attributes.style "max-height" (String.fromFloat height ++ "px")
           , Element.htmlAttribute <| Html.Attributes.style "min-height" (String.fromFloat height ++ "px")
           ]


{-| An implementation detail, but can be used directly in applications without elm-ui.
Returns the width and height of the block scaled to the width of a specified number of grid steps (including gutters), in pixels, Float.
-}
scaleProportionallyToWidthOfGridStepsFloat :
    LayoutState
    ->
        { originalWidth : Int
        , originalHeight : Int
        , widthSteps : Int
        }
    -> { width : Float, height : Float }
scaleProportionallyToWidthOfGridStepsFloat layout { originalWidth, originalHeight, widthSteps } =
    let
        widthFloat : Float
        widthFloat =
            widthOfGridStepsFloat layout widthSteps
    in
    { width = widthFloat
    , height = widthFloat * (toFloat originalHeight / toFloat originalWidth)
    }
