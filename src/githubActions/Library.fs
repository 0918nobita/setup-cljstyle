module GitHubActions

type Path = Path of string

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
