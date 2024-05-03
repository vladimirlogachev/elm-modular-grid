module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoDebug.Log
import NoDebug.TodoOrToString
import NoExposingEverything
import NoImportingEverything
import NoMissingSubscriptionsCall
import NoMissingTypeAnnotation
import NoMissingTypeAnnotationInLetIn
import NoPrematureLetComputation
import NoRecursiveUpdate
import NoSimpleLetBody
import NoTestValuesInProductionCode
import NoUnoptimizedRecursion
import NoUnsafeDivision
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import NoUselessSubscriptions
import Review.Rule as Rule exposing (Rule)
import Simplify


config : List Rule
config =
    [ NoDebug.Log.rule
    , NoDebug.TodoOrToString.rule
    , NoUnoptimizedRecursion.rule (NoUnoptimizedRecursion.optOutWithComment "IGNORE TCO")
    , Simplify.rule Simplify.defaults
    , NoTestValuesInProductionCode.rule
        (NoTestValuesInProductionCode.startsWith "stub_")
    , NoMissingSubscriptionsCall.rule
    , NoRecursiveUpdate.rule
    , NoUselessSubscriptions.rule
    , NoUnsafeDivision.rule |> Rule.ignoreErrorsForFiles [ "src/GridLayout1.elm", "src/GridLayout2.elm", "src/GridLayout3.elm" ]
    , NoUnused.CustomTypeConstructors.rule [] |> Rule.ignoreErrorsForFiles [ "src/GridLayout1.elm", "src/GridLayout2.elm", "src/GridLayout3.elm" ]
    , NoUnused.CustomTypeConstructorArgs.rule |> Rule.ignoreErrorsForFiles [ "src/GridLayout1.elm", "src/GridLayout2.elm", "src/GridLayout3.elm" ]
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule |> Rule.ignoreErrorsForFiles [ "src/GridLayout1.elm", "src/GridLayout2.elm", "src/GridLayout3.elm" ]
    , NoUnused.Modules.rule
    , NoUnused.Parameters.rule
    , NoUnused.Patterns.rule
    , NoExposingEverything.rule
    , NoUnused.Variables.rule
    , NoImportingEverything.rule [ "Element" ]
    , NoMissingTypeAnnotation.rule
    , NoMissingTypeAnnotationInLetIn.rule
    , NoPrematureLetComputation.rule
    , NoSimpleLetBody.rule
    ]
