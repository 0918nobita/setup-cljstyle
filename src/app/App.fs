module App

open GitHubActions
open GitHubRest

GitHubActionsTest.Instance.GetInput "name"
|> printfn "getInput => %A"

promise {
    let! version = GitHubRestTest.Instance.FetchLatestRelease {
        authToken = "token"
        owner = "owner"
        repo = "repo"
    }
    printfn "fetchLatestRelease => %A" version
}
|> ignore
