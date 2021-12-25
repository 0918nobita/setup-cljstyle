// fsharplint:disable memberNames

module GitHubActions.Test

open Type

type GitHubActionsTest private () =
    static member instance = GitHubActionsTest()

    static member inline addPath(_path: Path) = ()

    static member inline getInput(_name: string) = "value"

    static member inline group(f: ^a -> ^b) = f
