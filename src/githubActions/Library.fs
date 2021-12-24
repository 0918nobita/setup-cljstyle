module GitHubActions

type Path = Path of string

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
