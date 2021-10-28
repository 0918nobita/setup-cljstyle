module Test.Main where

import Prelude
import Effect (Effect)
import Effect.Aff (launchAff_)
import SetupCljstyle.Types (ErrorMessage(..))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)

main :: Effect Unit
main = do
  launchAff_
    $ runSpec [ consoleReporter ] do
        describe "ErrorMessage" do
          it "associativity" do
            let
              a = ErrorMessage "A"
            let
              b = ErrorMessage "B"
            let
              c = ErrorMessage "C"
            ((a <> b) <> c) `shouldEqual` (a <> (b <> c))
