module Test.RawInputSource where

import Prelude

import SetupCljstyle.RawInputSource (RawInputSource(..))

testRawInputSource :: String -> RawInputSource
testRawInputSource version = RawInputSource $
  pure
    { cljstyleVersion: version
    , authToken: "TOKEN"
    , runCheck: "false"
    }
