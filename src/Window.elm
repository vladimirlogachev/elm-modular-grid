module Window exposing
    ( ScreenClass(..)
    , Window
    , WindowSizeJs
    , actualContentWidth
    , fromWindowSizeJs
    , heightOfGridSteps
    , initWindowSizeJs
    , perScreen
    , spacingEqualToGridGutter
    , widthOfGridSteps
    , windowSizeJsDecoder
    )

import Constants
import Element exposing (Attribute, Element)
import Html.Attributes
import Json.Decode


type alias Window =
    { width : Int
    , height : Int
    , screenClass : ScreenClass
    }


type ScreenClass
    = SmallScreen
    | BigScreen


classifyScreen : WindowSizeJs -> ScreenClass
classifyScreen { width } =
    if width < Constants.bigScreenStartsFrom then
        SmallScreen

    else
        BigScreen


fromWindowSizeJs : WindowSizeJs -> Window
fromWindowSizeJs ws =
    { width = ws.width, height = ws.height, screenClass = classifyScreen ws }


perScreen : ScreenClass -> { small : a, big : a } -> a
perScreen screenClass { small, big } =
    case screenClass of
        SmallScreen ->
            small

        BigScreen ->
            big


type alias WindowSizeJs =
    { width : Int
    , height : Int
    }


windowSizeJsDecoder : Json.Decode.Decoder WindowSizeJs
windowSizeJsDecoder =
    Json.Decode.map2 WindowSizeJs
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)


{-| Stub for init
-}
initWindowSizeJs : WindowSizeJs
initWindowSizeJs =
    { width = 1024, height = 768 }


{-| Note: Attention! whenever you change layout width rules, you must rearrange this function!
-}
actualContentWidth : Window -> Int
actualContentWidth window =
    case window.screenClass of
        SmallScreen ->
            max Constants.minimalSupportedMobileScreenWidth window.width - (Constants.gridMarginSmallScreen * 2)

        BigScreen ->
            min Constants.contentWithPaddingsMaxWidthBigScreen window.width - (Constants.gridMarginBigScreen * 2)


{-| For cases when there is only one layout for both screen classes.
Otherwise, use values from the Constants module.
-}
spacingEqualToGridGutter : ScreenClass -> Int
spacingEqualToGridGutter screenClass =
    case screenClass of
        SmallScreen ->
            Constants.gridGutterSmallScreen

        BigScreen ->
            Constants.gridGutterBigScreen


gridStepsCount : Float
gridStepsCount =
    12


{-| Implementation detail
-}
widthOfGridStepsFloat : Window -> Int -> Float
widthOfGridStepsFloat window numberOfSteps =
    let
        gutterCountBetween =
            numberOfSteps - 1

        gutterWidth =
            spacingEqualToGridGutter window.screenClass

        contentWidth =
            actualContentWidth window

        stepWidth =
            (toFloat contentWidth - toFloat gutterWidth * (gridStepsCount - 1))
                / gridStepsCount
    in
    (stepWidth * toFloat numberOfSteps) + (toFloat gutterWidth * toFloat gutterCountBetween)


widthOfGridSteps : Window -> Int -> List (Attribute msg)
widthOfGridSteps window numberOfSteps =
    let
        baseWidth =
            widthOfGridStepsFloat window numberOfSteps
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


heightOfGridSteps : Window -> Int -> List (Attribute msg)
heightOfGridSteps window numberOfSteps =
    let
        baseHeight =
            widthOfGridStepsFloat window numberOfSteps
    in
    [ Element.height Element.fill
    , Element.htmlAttribute <| Html.Attributes.style "max-height" (String.fromInt (ceiling baseHeight) ++ "px")
    , Element.htmlAttribute <| Html.Attributes.style "min-height" (String.fromFloat baseHeight ++ "px")
    ]
