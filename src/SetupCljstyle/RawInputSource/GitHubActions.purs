module SetupCljstyle.RawInputSource.GitHubActions where

import Control.Monad.Except (mapExceptT)
import Effect.Class (liftEffect)
import GitHub.Actions.Extension (inputExceptT)
import Prelude
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
  { cljstyleVersion: mapExceptT liftEffect $ inputExceptT "cljstyle-version"
  , authToken: mapExceptT liftEffect $ inputExceptT "token"
  , runCheck: mapExceptT liftEffect $ inputExceptT "run-check"
  }
