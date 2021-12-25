// fsharplint:disable recordFieldNames

module GitHubRest.Types

[<Struct>]
type FetchLatestReleaseArgs = {
    authToken: string
    owner: string
    repo: string
}

type Version = Version of string
