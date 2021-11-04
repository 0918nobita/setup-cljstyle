module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff (launchAff_)
import Types (SingleError(..))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

main :: Effect Unit
main = do
  launchAff_ $ runSpec [ consoleReporter ] do
    describe "SingleError" do
      it "associativity" do
        let
          a = SingleError "A"
          b = SingleError "B"
          c = SingleError "C"
        ((a <> b) <> c) `shouldEqual` (a <> (b <> c))
