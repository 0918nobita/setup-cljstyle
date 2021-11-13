module Test.Fetcher where

import Prelude

import Fetcher (class Fetcher)

data TestFetcher = TestFetcher String

instance Fetcher TestFetcher where
  getText (TestFetcher resBody) _ = pure resBody
