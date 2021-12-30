# Development Guide

## Requirements

- [.NET 6.0 SDK](https://dotnet.microsoft.com/en-us/)
- [Node.js](https://nodejs.org/en/)
- [pnpm](https://pnpm.io)

## Install dotnet tools

```bash
dotnet tool restore
```

## Install dependencies

```bash
dotnet paket restore
dotnet restore
pnpm install
```

## Build

```bash
pnpm build && pnpm bundle
```

## Lint

```bash
dotnet fsharplint lint setup-cljstyle.sln
```

## Format code

```bash
dotnet fantomas --recurse src
```

## Test

```bash
dotnet test
```
