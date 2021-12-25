module GitHubActions

open Fable.Core

type Path =
    private
    | Path of string

[<Import("addPath", "@actions/core")>]
let private addPathNative: string -> unit = jsNative

[<Import("getInput", "@actions/core")>]
let private getInputNative: string -> string = jsNative

type GitHubActionsImpl private () =
    static member instance = GitHubActionsImpl()

    static member inline addPath(Path(path)) = addPathNative path

    static member inline getInput(name) = getInputNative name

type GitHubActionsTest private () =
    static member instance = GitHubActionsTest()

    static member inline addPath(_path: Path) = ()

    static member inline getInput(_name: string) = "value"

    static member inline group(f: ^a -> ^b) = f

let inline addPath (_gha: ^g) (path: Path) =
    (^g: (static member addPath: Path -> unit) path)

let inline getInput (_gha: ^g) (name: string) =
    (^g: (static member getInput: string -> string) name)

let inline group (_gha: ^g) (f: ^a -> ^b) =
    (^g: (static member group: (^a -> ^b) -> (^a -> ^b)) f)
