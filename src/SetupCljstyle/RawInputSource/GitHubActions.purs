module SetupCljstyle.RawInputSource.GitHubActions where

import Prelude

import GitHub.Actions.Extension (getInput)
import SetupCljstyle.RawInputSource (class HasRawInputs)
import Types (AffWithExcept)

newtype GHARawInputSource = GHARawInputSource
  { cljstyleVersion :: AffWithExcept String
  , authToken :: AffWithExcept String
  , runCheck :: AffWithExcept String
  }

instance HasRawInputs GHARawInputSource where
  gatherRawInputs (GHARawInputSource s) = do
    cljstyleVersion <- s.cljstyleVersion
    authToken <- s.authToken
    runCheck <- s.runCheck
    pure { cljstyleVersion, authToken, runCheck }

ghaRawInputSource :: GHARawInputSource
ghaRawInputSource = GHARawInputSource
  { cljstyleVersion: getInput "cljstyle-version"
  , authToken: getInput "token"
  , runCheck: getInput "run-check"
  }
