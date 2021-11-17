module Fetcher.Node
  ( textFetcher
  ) where

import Prelude

import Control.Monad.Trans.Class (lift)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Fetcher (TextFetcher(..), FetchTextArgs)

foreign import _fetchTextImpl :: FetchTextArgs -> EffectFnAff String

fetchTextImpl :: FetchTextArgs -> Aff String
fetchTextImpl = fromEffectFnAff <<< _fetchTextImpl

textFetcher :: TextFetcher
textFetcher = TextFetcher (lift <<< fetchTextImpl)
