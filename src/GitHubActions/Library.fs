module GitHubActions.Invoke

open Fable.Core
open Types

let inline addPath (_gha: ^g) (path: Path) =
    (^g: (static member addPath : Path -> unit) path)

let inline getInput (_gha: ^g) (name: string) =
    (^g: (static member getInput : string -> string) name)

type PromiseFn<'a, 'b> = 'a -> JS.Promise<'b>

let inline group (title: string) (f: PromiseFn< ^a, ^b >) : PromiseFn< ^a, ^b > =
    fun a ->
        promise {
            printfn "::group::%s" title
            let! b = f a
            printfn "::endgroup::"
            return b
        }
