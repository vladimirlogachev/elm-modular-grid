module Window exposing
    ( ScreenClass(..)
    , WindowSize
    , classifyScreen
    , contentWidth
    , initWindowSize
    , perScreen
    , windowSizeDecoder
    )

import Constants
import Json.Decode


type alias WindowSize =
    { width : Int
    , height : Int
    }


type ScreenClass
    = SmallScreen
    | BigScreen




classifyScreen : WindowSize -> ScreenClass
classifyScreen { width } =
    if width < Constants.bigScreenStartsFrom then
        SmallScreen

    else
        BigScreen


perScreen : ScreenClass -> { small : a, big : a } -> a
perScreen screenClass { small, big } =
    case screenClass of
        SmallScreen ->
            small

        BigScreen ->
            big

       
windowSizeDecoder : Json.Decode.Decoder WindowSize
windowSizeDecoder =
    Json.Decode.map2 WindowSize
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)


{-| Stub for init
-}
initWindowSize : WindowSize
initWindowSize =
    { width = 1024, height = 768 }

{-| Note: Attention! whenever you change layout width rules, you must rearrange this function! 
-}
contentWidth : { shared | window : WindowSize, screenClass : ScreenClass } -> Int
contentWidth shared =
    case shared.screenClass of
        SmallScreen ->
            max Constants.minimalSupportedMobileScreenWidth shared.window.width - (Constants.layoutPaddingSmallScreen * 2)

        BigScreen ->
            min Constants.contentWithPaddingsMaxWidthBigScreen shared.window.width - (Constants.layoutPaddingBigScreen * 2)
