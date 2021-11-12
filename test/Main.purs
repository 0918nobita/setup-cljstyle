module Test.Main where

import Control.Monad.Except (runExceptT)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Prelude
import SetupCljstyle.InputResolver (resolveInputs)
import SetupCljstyle.RawInputSource (gatherRawInputs)
import Test.Fetcher (TestFetcher(..))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (runSpec)
import Test.RawInputSource (testRawInputSource)
import Types (SingleError(..), Version(..))

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

    describe "InputResolver" do
      describe "resolveInputs" do
        let fetcher = TestFetcher "{ \"tag_name\":\"0.15.0\"}"
        it "when the cljstyle's version is specified" do
          result <- runExceptT do
            rawInputs <- gatherRawInputs $ testRawInputSource "0.14.0"
            resolveInputs { fetcher, rawInputs }

          result `shouldEqual` Right { cljstyleVersion: Version "0.14.0", runCheck: false }

        it "when the cljstyle's version is not specified" do
          result <- runExceptT do
            rawInputs <- gatherRawInputs $ testRawInputSource ""
            resolveInputs { fetcher, rawInputs }

          result `shouldEqual` Right { cljstyleVersion: Version "0.15.0", runCheck: false }
