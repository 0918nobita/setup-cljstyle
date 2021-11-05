module Test.RawInputSource where

import Prelude
import SetupCljstyle.InputResolver (class HasRawInputs)
import Types (AffWithExcept)

newtype TestRawInputSource = TestRawInputSource
  { cljstyleVersion :: AffWithExcept String
  , authToken :: AffWithExcept String
  , runCheck :: AffWithExcept String
  }

instance HasRawInputs TestRawInputSource where
  getCljstyleVersion (TestRawInputSource { cljstyleVersion }) = cljstyleVersion
  getAuthToken (TestRawInputSource { authToken }) = authToken
  getRunCheck (TestRawInputSource { runCheck }) = runCheck

testRawInputSource :: TestRawInputSource
testRawInputSource = TestRawInputSource
  { cljstyleVersion: pure "0.15.0"
  , authToken: pure "TOKEN"
  , runCheck: pure "false"
  }
