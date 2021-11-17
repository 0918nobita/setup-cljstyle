module GitHub.RestApi.Releases
  ( fetchLatestRelease
  ) where

import Prelude

import Control.Monad.Except (except)
import Data.Argonaut (decodeJson, jsonParser, printJsonDecodeError)
import Data.EitherR (fmapL)
import Fetcher (TextFetcher, fetchText)
import Types (AffWithExcept, SingleError(..), Version(..))

type Release = { tag_name :: String }

type FetchLatestReleaseArgs =
  { authToken :: String
  , owner :: String
  , repo :: String
  }

fetchLatestRelease :: TextFetcher -> FetchLatestReleaseArgs -> AffWithExcept Version
fetchLatestRelease fetcher { authToken, owner, repo } = do
  let url = "https://api.github.com/repos/" <> owner <> "/" <> repo <> "/releases/latest"
  resBody <- fetchText fetcher { url, authorization: "Bearer " <> authToken }

  parsed <- except $ jsonParser resBody # fmapL SingleError

  decoded :: Release <- except $ decodeJson parsed # fmapL (printJsonDecodeError >>> SingleError)

  pure $ Version decoded.tag_name
