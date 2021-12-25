// fsharplint:disable memberNames

module GitHubRest.Impl

open Octokit
open Types

type GitHubRestImpl private () =
    static member instance = GitHubRestImpl()

    static member inline fetchLatestRelease(args: FetchLatestReleaseArgs) =
        promise {
            let! res = (getOctokit args.authToken).rest.repos.getLatestRelease {
                owner = args.owner
                repo = args.repo
            }
            return Version res.data.tagName
        }
