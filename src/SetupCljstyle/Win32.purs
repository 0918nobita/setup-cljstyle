module SetupCljstyle.Win32 where

import Prelude

import Effect (Effect)
import Effect.Class.Console (info)
import SetupCljstyle.Types (Version)

installBin :: Version -> Effect Unit
installBin _ = info "win32"
