# setup-cljstyle

Install [cljstyle](https://github.com/greglook/cljstyle)

## Usage

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: 0918nobita/setup-cljstyle@v0.4.0
    with:
      cljstyle-version: "0.15.0"
  - run: cljstyle version
  - run: cljstyle check
```

`cljstyle-version` is optional. If omitted, the latest version of cljstyle will be installed.

## Supported runners

- `windows-latest`
- `macos-latest`
- `ubuntu-latest`
