module Constants exposing (..)


minimalSupportedMobileScreenWidth : Int
minimalSupportedMobileScreenWidth =
    360


bigScreenStartsFrom : Int
bigScreenStartsFrom =
    720


{-| Includes minimal margins.
-}
contentWithPaddingsMaxWidthBigScreen : Int
contentWithPaddingsMaxWidthBigScreen =
    1512


gridMarginBigScreen : Int
gridMarginBigScreen =
    32


gridMarginSmallScreen : Int
gridMarginSmallScreen =
    16


gridGutterBigScreen : Int
gridGutterBigScreen =
    32


gridGutterSmallScreen : Int
gridGutterSmallScreen =
    16
