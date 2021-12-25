module GitHubRest.Octokit

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
