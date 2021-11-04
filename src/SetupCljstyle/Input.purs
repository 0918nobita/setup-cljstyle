module SetupCljstyle.Input
  ( Inputs
  , gatherInputs
  ) where

import Control.Monad.Except (except, mapExceptT)
import Data.Argonaut (jsonParser)
import Data.Argonaut.Decode.Decoders (decodeBoolean)
import Data.EitherR (fmapL)
import Effect.Class (liftEffect)
import GitHub.Actions.Extension (inputExceptT)
import Prelude
import SetupCljstyle.Input.Version (cljstyleVersionInput)
import Types (AffWithExcept, SingleError(..), Version)

type Inputs =
  { cljstyleVersion :: Version
  , authToken :: String
  , runCheck :: Boolean
  }

gatherInputs :: AffWithExcept Inputs
gatherInputs = do
  cljstyleVersion <- cljstyleVersionInput

  mapExceptT liftEffect do
    authToken <- inputExceptT "token"

    runCheckRawStr <- inputExceptT "run-check"
    parsed <- except $ jsonParser runCheckRawStr # fmapL \_ -> SingleError "Failed to parse `run-check` input"
    runCheck <- except $ decodeBoolean parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."

    pure { cljstyleVersion, authToken, runCheck }
