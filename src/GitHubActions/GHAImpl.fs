// fsharplint:disable memberNames

module GitHubActions.Impl

open Fable.Core
open Types

[<Import("addPath", "@actions/core")>]
let addPathNative: string -> unit = jsNative

[<Import("getInput", "@actions/core")>]
let getInputNative: string -> string = jsNative

type GitHubActionsImpl private () =
    static member instance = GitHubActionsImpl()

    static member inline addPath(Path (path)) = addPathNative path

    static member inline getInput(name) = getInputNative name
