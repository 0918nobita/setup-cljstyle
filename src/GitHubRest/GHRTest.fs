module GitHubRest.Test

open Types

type GitHubRestTest private () =
    static member instance = GitHubRestTest()

    static member inline fetchLatestRelease(_args: FetchLatestReleaseArgs) =
        Promise.lift (Version "0.15.0")
