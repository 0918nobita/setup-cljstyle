module App

type IGitHubActions =
    abstract member AddPath : string -> unit
    abstract member GetInput : string -> string
    abstract member Group : ('a -> 'b) -> ('a -> 'b)

type GitHubActionsTest =
    interface IGitHubActions with
        member _.AddPath(_path: string) = ()
        member _.GetInput(_name: string) = "value"
        member _.Group(f: 'a -> 'b) = f

printfn "Hello from F#"
