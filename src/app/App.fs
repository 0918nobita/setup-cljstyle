module App

open GitHubActions
open GitHubRest

getInput GitHubActionsTest.instance "name"
|> printfn "getInput => %A"

promise {
    let! version = fetchLatestRelease GitHubRestTest.instance {
        authToken = "token"
        owner = "owner"
        repo = "repo"
    }
    printfn "fetchLatestRelease => %A" version
}
|> ignore
