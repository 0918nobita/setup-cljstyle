module GitHubRest.Invoke

open Fable.Core
open Types

let inline fetchLatestRelease (_ghr: ^g) (args: FetchLatestReleaseArgs) =
    (^g: (static member fetchLatestRelease : FetchLatestReleaseArgs -> JS.Promise<Version>) args)
