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

testRawInputSource :: String -> TestRawInputSource
testRawInputSource version = TestRawInputSource
  { cljstyleVersion: pure version
  , authToken: pure "TOKEN"
  , runCheck: pure "false"
  }
