module SetupCljstyle.Inputs
  ( cljstyleVersionInput
  , authTokenInput
  , runCheckInput
  ) where

import Control.Monad.Except (ExceptT, except, withExceptT)
import Data.Argonaut (jsonParser)
import Data.Argonaut.Decode.Decoders (decodeBoolean)
import Data.EitherR (fmapL)
import Data.Maybe (Maybe(Nothing))
import Effect (Effect)
import GitHub.Actions.Core (getInput)
import Prelude
import SetupCljstyle.Types (SingleError(..))

inputExceptT :: String -> ExceptT (SingleError String) Effect String
inputExceptT name =
  getInput { name, options: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to get `" <> name <> "` input"

cljstyleVersionInput :: ExceptT (SingleError String) Effect String
cljstyleVersionInput = inputExceptT "cljstyle-version"

authTokenInput :: ExceptT (SingleError String) Effect String
authTokenInput = inputExceptT "token"

runCheckInput :: ExceptT (SingleError String) Effect Boolean
runCheckInput = do
  runCheckRawStr <- inputExceptT "run-check"
  parsed <- except $ jsonParser runCheckRawStr # fmapL \_ -> SingleError "Failed to parse `run-check` input"
  except $ decodeBoolean parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."
