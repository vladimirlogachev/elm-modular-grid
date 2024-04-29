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

layoutPaddingBigScreen : Int
layoutPaddingBigScreen = 32

layoutPaddingSmallScreen : Int
layoutPaddingSmallScreen = 16