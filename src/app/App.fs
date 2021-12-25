module App

open GitHubActions
open GitHubRest

getInput GitHubActionsImpl.instance "cljstyle-version"
|> printfn "Specified cljstyle version: %s"

let authToken = getInput GitHubActionsImpl.instance "token"

promise {
    let! version = fetchLatestRelease GitHubRestImpl.instance {
        authToken = authToken
        owner = "greglook"
        repo = "cljstyle"
    }
    printfn "Fetched latest release: %A" version
}
|> ignore
