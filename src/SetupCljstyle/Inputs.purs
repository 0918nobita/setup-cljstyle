module SetupCljstyle.Inputs
  ( cljstyleVersionInput
  , authTokenInput
  , runCheckInput
  ) where

import Control.Monad.Except.Trans (ExceptT, except, withExceptT)
import Data.Argonaut (jsonParser)
import Data.Argonaut.Decode.Decoders (decodeBoolean)
import Data.Maybe (Maybe(Nothing))
import Effect (Effect)
import GitHub.Actions.Core (getInput)
import Prelude
import SetupCljstyle.Types (ErrorMessage(..))

inputExceptT :: String -> ExceptT ErrorMessage Effect String
inputExceptT name =
  getInput { name, options: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to get `" <> name <> "` input")

cljstyleVersionInput :: ExceptT ErrorMessage Effect String
cljstyleVersionInput = inputExceptT "cljstyle-version"

authTokenInput :: ExceptT ErrorMessage Effect String
authTokenInput = inputExceptT "token"

runCheckInput :: ExceptT ErrorMessage Effect Boolean
runCheckInput = do
  runCheckRawStr <- inputExceptT "run-check"
  parsed <- (except $ jsonParser runCheckRawStr) # withExceptT (\_ -> ErrorMessage "Failed to parse `run-check` input")
  (except $ decodeBoolean parsed) # withExceptT (\_ -> ErrorMessage "The format of `run-check` input is invalid.")
