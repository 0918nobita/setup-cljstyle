# setup-cljstyle

![Lint](https://github.com/0918nobita/setup-cljstyle/workflows/Lint/badge.svg)

Install [cljstyle](https://github.com/greglook/cljstyle)

## Usage

```yaml
steps:
  - uses: actions/checkout@v2
  - uses: 0918nobita/setup-cljstyle@v0.1.0
    with:
      cljstyle-version: 0.13.0 # default: 0.13.0
  - run: cljstyle version
  - run: cljstyle check
```
