# setup-cljstyle

Install [cljstyle](https://github.com/greglook/cljstyle)

## Usage

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: 0918nobita/setup-cljstyle@v0.3.0
    with:
      cljstyle-version: 0.15.0 # default: 0.15.0
  - run: cljstyle version
  - run: cljstyle check
```

## Supported runners

- `windows-latest`
- `macos-latest`
- `ubuntu-latest`
