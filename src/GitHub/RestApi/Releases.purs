module GitHub.RestApi.Releases where

import Prelude

import Control.Monad.Except (ExceptT(..))
import Control.Promise (Promise, toAff)
import Data.Argonaut (decodeJson, jsonParser)
import Data.EitherR (fmapL)
import Effect.Aff (Aff)

foreign import _fetchLatestRelease :: String -> String -> Promise String

type Release = { tag_name :: String }

data Error = FailedToParse
           | FailedToDecode

instance showError :: Show Error where
  show FailedToParse = "Failed to parse JSON"
  show FailedToDecode = "Failed to decode the received JSON data"

fetchLatestRelease :: String -> String -> ExceptT Error Aff String
fetchLatestRelease owner repo = ExceptT do
  release <- toAff $ _fetchLatestRelease owner repo

  pure do
    parsed <- jsonParser release # fmapL (\_ -> FailedToParse)
    decoded :: Release <- decodeJson parsed # fmapL (\_ -> FailedToDecode)
    pure decoded.tag_name
