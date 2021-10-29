module GitHub.RestApi.Releases
  ( fetchLatestRelease
  ) where

import Prelude
import Control.Monad.Except (ExceptT, except, lift)
import Data.Argonaut (decodeJson, jsonParser, printJsonDecodeError)
import Data.EitherR (fmapL)
import Effect.Aff (Aff)
import Foreign.Object (singleton)
import Milkis (getMethod)
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import SetupCljstyle.Types (Version(..), ErrorMessage(..))

type FetchLatestReleaseArgs =
  { authToken :: String
  , owner :: String
  , repo :: String
  }

type Release = { tag_name :: String }

fetch :: M.Fetch
fetch = M.fetch nodeFetch

fetchLatestRelease :: FetchLatestReleaseArgs -> ExceptT ErrorMessage Aff Version
fetchLatestRelease args = do
  let url = "https://api.github.com/repos/" <> args.owner <> "/" <> args.repo <> "/releases/latest"
  res <- lift $ fetch (M.URL url)
    { method: getMethod
    , headers: singleton "Authorization" $ "Bearer " <> args.authToken
    }
  resBody <- lift $ M.text res
  parsed <- except $ jsonParser resBody # fmapL ErrorMessage
  decoded :: Release <- except $ decodeJson parsed # fmapL (ErrorMessage <<< printJsonDecodeError)
  pure $ Version decoded.tag_name
