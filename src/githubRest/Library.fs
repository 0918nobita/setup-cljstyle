module GitHubRest

open Fable.Core

[<Struct>]
type GetLatestReleaseArgs = {
    owner: string
    repo: string
}

type IRelease =
    [<Emit("$0.tag_name")>]
    abstract member tagName: string

type IGetLatestReleaseResult =
    abstract member data: IRelease

type IRepos =
    abstract member getLatestRelease: GetLatestReleaseArgs -> JS.Promise<IGetLatestReleaseResult>

type IRest =
    abstract member repos: IRepos

type IOctokit =
    abstract member rest: IRest

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

    static member inline fetchLatestRelease(args: FetchLatestReleaseArgs) =
        promise {
            let! res = (getOctokit args.authToken).rest.repos.getLatestRelease {
                owner = args.owner
                repo = args.repo
            }
            return Version res.data.tagName
        }

type GitHubRestTest private () =
    static member instance = GitHubRestTest()

    static member inline fetchLatestRelease(args: FetchLatestReleaseArgs) =
        Promise.lift (Version "0.15.0")

let inline fetchLatestRelease (_ghr: ^g) (args: FetchLatestReleaseArgs) =
    (^g: (static member fetchLatestRelease: FetchLatestReleaseArgs -> JS.Promise<Version>) args)
