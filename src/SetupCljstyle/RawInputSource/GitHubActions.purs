module SetupCljstyle.RawInputSource.GitHubActions where

import Prelude

import GitHub.Actions.Extension (getInput)
import SetupCljstyle.RawInputSource (RawInputSource(..))

rawInputSource :: RawInputSource
rawInputSource = RawInputSource do
  cljstyleVersion <- getInput "cljstyle-version"
  authToken <- getInput "token"
  runCheck <- getInput "run-check"
  pure { cljstyleVersion, authToken, runCheck }
