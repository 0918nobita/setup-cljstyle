module Test.Fetcher where

import Prelude

import Fetcher (TextFetcher(..))

testTextFetcher :: String -> TextFetcher
testTextFetcher resBody = TextFetcher (\_ -> pure resBody)
