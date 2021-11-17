module SetupCljstyle.Command where

import Prelude

import Effect (Effect)
import Node.ChildProcess (defaultExecSyncOptions, execSync)

execCmd :: String -> Effect Unit
execCmd cmd = void $ execSync cmd defaultExecSyncOptions
