module GitHubRest

open Fable.Core

type IOctokit = interface end

type IRest = interface end

[<Struct>]
type GetLatestReleaseArgs = {
    owner: string
    repo: string
}

type IRepos =
    abstract member getLatestRelease: GetLatestReleaseArgs -> JS.Promise<obj>

[<Import("getOctokit", "@actions/github")>]
let getOctokit: string -> IOctokit = jsNative

[<Emit("$0.rest")>]
let getRest (_octokit: IOctokit): IRest = jsNative

[<Emit("$0.repos")>]
let getRepo (_rest: IRest): IRepos = jsNative

type Version = Version of string

[<Struct>]
type FetchLatestReleaseArgs = {
    authToken: string
    owner: string
    repo: string
}

type GitHubRestImpl private () =
    static member instance = GitHubRestImpl()

    static member inline fetchLatestRelease(args: FetchLatestReleaseArgs) =
        let repo =
            getOctokit args.authToken
            |> getRest
            |> getRepo
        JS.console.dir <| repo.getLatestRelease { owner = "greglook"; repo = "cljstyle" }
        Promise.lift (Version "0.15.0")

type GitHubRestTest private () =
    static member instance = GitHubRestTest()

    static member inline fetchLatestRelease(args: FetchLatestReleaseArgs) =
        let repo =
            getOctokit args.authToken
            |> getRest
            |> getRepo
        JS.console.dir repo.getLatestRelease
        Promise.lift (Version "0.15.0")

let inline fetchLatestRelease (_ghr: ^g) (args: FetchLatestReleaseArgs) =
    (^g: (static member fetchLatestRelease: FetchLatestReleaseArgs -> JS.Promise<Version>) args)
