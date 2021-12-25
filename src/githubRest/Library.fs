module GitHubRest

open Fable.Core

type IPulls =
    abstract get: obj -> obj

type IRest =
    abstract pulls: IPulls

type IOctokit =
    abstract rest: IRest

[<Import("getOctokit", "@actions/github")>]
let getOctokit: string -> IOctokit = jsNative

type Version = Version of string

[<Struct>]
type FetchLatestReleaseArgs = {
    authToken: string
    owner: string
    repo: string
}

type GitHubRestImpl private () =
    static member instance = GitHubRestImpl()

    static member inline fetchLatestRelease(_args: FetchLatestReleaseArgs) =
        Promise.lift (Version "0.15.0")

type GitHubRestTest private () =
    static member instance = GitHubRestTest()

    static member inline fetchLatestRelease(args: FetchLatestReleaseArgs) =
        let octokit = getOctokit args.authToken
        JS.console.dir octokit.rest
        Promise.lift (Version "0.15.0")

let inline fetchLatestRelease (_ghr: ^g) (args: FetchLatestReleaseArgs) =
    (^g: (static member fetchLatestRelease: FetchLatestReleaseArgs -> JS.Promise<Version>) args)
