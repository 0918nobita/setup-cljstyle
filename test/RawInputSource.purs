module Test.RawInputSource where

import Prelude
import SetupCljstyle.RawInputSource (class HasRawInputs)
import Types (AffWithExcept)

newtype TestRawInputSource = TestRawInputSource
  { cljstyleVersion :: AffWithExcept String
  , authToken :: AffWithExcept String
  , runCheck :: AffWithExcept String
  }

instance HasRawInputs TestRawInputSource where
  gatherRawInputs (TestRawInputSource { cljstyleVersion, authToken, runCheck }) = do
    cljstyleVersion' <- cljstyleVersion
    authToken' <- authToken
    runCheck' <- runCheck
    pure { cljstyleVersion: cljstyleVersion', authToken: authToken', runCheck: runCheck' }

testRawInputSource :: TestRawInputSource
testRawInputSource = TestRawInputSource
  { cljstyleVersion: pure "0.15.0"
  , authToken: pure "TOKEN"
  , runCheck: pure "false"
  }
