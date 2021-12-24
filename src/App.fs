module App

open Fable.Core

type Path = Path of string

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
type GitHubRestTest private () =
    static member Instance: IGitHubRest = GitHubRestTest()

    interface IGitHubRest with
        member _.FetchLatestRelease(_args: FetchLatestReleaseArgs) = Promise.lift (Version "0.15.0")

type IGitHubActions =
    abstract member AddPath : Path -> unit
    abstract member GetInput : string -> string
    abstract member Group : ('a -> 'b) -> ('a -> 'b)

[<Sealed>]
type GitHubActionsTest private () =
    static member Instance: IGitHubActions = GitHubActionsTest()

    interface IGitHubActions with
        member _.AddPath(_path: Path) = ()
        member _.GetInput(_name: string) = "value"
        member _.Group(f: 'a -> 'b) = f

promise {
    let! version = GitHubRestTest.Instance.FetchLatestRelease({
        authToken = "token"
        owner = "owner"
        repo = "repo"
    })
    printfn "%A" version
}
|> ignore
