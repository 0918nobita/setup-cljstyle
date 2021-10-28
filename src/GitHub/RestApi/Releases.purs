module GitHub.RestApi.Releases where

import Prelude

import Control.Monad.Except (ExceptT(..))
import Control.Promise (Promise, toAff)
import Data.Argonaut (decodeJson, jsonParser)
import Data.EitherR (fmapL)
import Effect.Aff (Aff)
import SetupCljstyle.Types (Version(..))

type FetchLatestReleaseArgs = {
  authToken :: String,
  owner :: String,
  repo :: String
}

foreign import _fetchLatestRelease :: FetchLatestReleaseArgs -> Promise String

type Release = { tag_name :: String }

data Error = FailedToParse
           | FailedToDecode

instance showError :: Show Error where
  show FailedToParse = "Failed to parse JSON"
  show FailedToDecode = "Failed to decode the received JSON data"

fetchLatestRelease :: FetchLatestReleaseArgs -> ExceptT Error Aff Version
fetchLatestRelease args = ExceptT do
  release <- toAff $ _fetchLatestRelease args

  pure do
    parsed <- jsonParser release # fmapL (\_ -> FailedToParse)
    decoded :: Release <- decodeJson parsed # fmapL (\_ -> FailedToDecode)
    pure $ Version decoded.tag_name
