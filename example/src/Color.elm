module Color exposing (bodyBackground, desktopScreenContentBackground, gridMarginBackground, mobileScreenContentBackground, white)

import Element exposing (..)



-- Colors to be used directly


white : Color
white =
    rgb255 255 255 255


mobileScreenContentBackground : Color
mobileScreenContentBackground =
    rgb255 0xB2 0xEB 0xF2



desktopScreenContentBackground : Color
desktopScreenContentBackground =
    rgb255 0xBB 0xDE 0xFB


bodyBackground : Color
bodyBackground =
    rgb255 0xCF 0xD8 0xDC


gridMarginBackground : Color
gridMarginBackground =
    rgb255 0xFF 0xE0 0xB2


