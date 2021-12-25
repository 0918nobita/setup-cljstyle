module App

open GitHubActions.Impl
open GitHubActions.Invoke
open GitHubRest.Impl
open GitHubRest.Invoke
open Thoth.Json

[<Struct>]
type MyType =
    | MyType of a: int * b: string

    static member Decoder: Decoder<MyType> =
        Decode.map2 (fun a b -> MyType(a, b)) (Decode.field "a" Decode.int) (Decode.field "b" Decode.string)

Decode.fromString MyType.Decoder """{ "a": 42, "b": "foo" }"""
|> printfn "Result: %A"

getInput GitHubActionsImpl.instance "cljstyle-version"
|> printfn "Specified cljstyle version: %s"

let authToken =
    getInput GitHubActionsImpl.instance "token"

promise {
    let! version =
        fetchLatestRelease
            GitHubRestImpl.instance
            { authToken = authToken
              owner = "greglook"
              repo = "cljstyle" }

    printfn "Fetched latest release: %A" version
}
|> ignore
