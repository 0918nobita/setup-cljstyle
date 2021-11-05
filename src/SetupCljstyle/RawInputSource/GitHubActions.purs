module SetupCljstyle.RawInputSource.GitHubActions where

import Control.Monad.Except (mapExceptT)
import Effect.Class (liftEffect)
import GitHub.Actions.Extension (inputExceptT)
import Prelude
import SetupCljstyle.InputResolver (class HasRawInputs)
import Types (AffWithExcept)

newtype GHARawInputSource = GHARawInputSource
  { cljstyleVersion :: AffWithExcept String
  , authToken :: AffWithExcept String
  , runCheck :: AffWithExcept String
  }

instance HasRawInputs GHARawInputSource where
  getCljstyleVersion (GHARawInputSource { cljstyleVersion }) = cljstyleVersion
  getAuthToken (GHARawInputSource { authToken }) = authToken
  getRunCheck (GHARawInputSource { runCheck }) = runCheck

ghaRawInputSource :: GHARawInputSource
ghaRawInputSource = GHARawInputSource
  { cljstyleVersion: mapExceptT liftEffect $ inputExceptT "cljstyle-version"
  , authToken: mapExceptT liftEffect $ inputExceptT "token"
  , runCheck: mapExceptT liftEffect $ inputExceptT "run-check"
  }
