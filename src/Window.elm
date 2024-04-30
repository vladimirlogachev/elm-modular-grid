module Window exposing
    ( ScreenClass(..)
    , Window
    , WindowSizeJs
    , actualContentWidth
    , fromWindowSizeJs
    , gridSteps3
    , initWindowSizeJs
    , perScreen
    , spacingEqualToGridGutter
    , windowSizeJsDecoder
    )

import Constants
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


gridSteps3 : Window -> Int -> Float
gridSteps3 window numberOfSteps =
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
