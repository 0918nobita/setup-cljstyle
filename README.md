<h1 align="center">setup-cljstyle</h1>

<p align="center">Install <a href="https://github.com/greglook/cljstyle" target="_blank" rel="noopener noreferrer">cljstyle</a></p>

<p align="center">
  <a href="https://github.com/marketplace/actions/set-up-cljstyle">Available on Marketplace</a>
  ·
  <a href="#Usage">Usage</a>
  ·
  <a href="./DEVGUIDE.md">Development Guide</a>
</p>

<p align="center">
  <a href="https://github.com/0918nobita/setup-cljstyle/actions/workflows/lint.yml">
    <img alt="Lint" src="https://github.com/0918nobita/setup-cljstyle/actions/workflows/lint.yml/badge.svg">
  </a>&nbsp;
  <a href="https://github.com/0918nobita/setup-cljstyle/actions/workflows/test.yml">
    <img alt="Test" src="https://github.com/0918nobita/setup-cljstyle/actions/workflows/test.yml/badge.svg">
  </a>
</p>

<hr>

## Usage

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: 0918nobita/setup-cljstyle@v0.4.2
    with:
      cljstyle-version: "0.15.0"
  - run: cljstyle version
  - run: cljstyle check
```

### Inputs

#### `cljstyle-version`

Optional. If omitted, the latest version of cljstyle will be installed.

#### `token`

Default is ``${{ github.token }}``.

## Supported runners

- `windows-latest`
- `macos-latest`
- `ubuntu-latest`
