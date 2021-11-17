module Fetcher where

import Types (AffWithExcept)

type FetchTextArgs = { url :: String, authorization :: String }

newtype TextFetcher = TextFetcher (FetchTextArgs -> AffWithExcept String)

fetchText :: TextFetcher -> FetchTextArgs -> AffWithExcept String
fetchText (TextFetcher fn) = fn
