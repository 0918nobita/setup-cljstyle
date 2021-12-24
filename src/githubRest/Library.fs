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

type IGitHubRest =
    abstract member FetchLatestRelease : FetchLatestReleaseArgs -> JS.Promise<Version>

[<Sealed>]
type GitHubRestImpl private () =
    static member Instance: IGitHubRest = GitHubRestImpl()

    interface IGitHubRest with
        member _.FetchLatestRelease(_args: FetchLatestReleaseArgs) =
            Promise.lift (Version "0.15.0")

[<Sealed>]
type GitHubRestTest private () =
    static member Instance: IGitHubRest = GitHubRestTest()

    interface IGitHubRest with
        member _.FetchLatestRelease(args: FetchLatestReleaseArgs) =
            let octokit = getOctokit args.authToken
            JS.console.dir octokit.rest
            Promise.lift (Version "0.15.0")
