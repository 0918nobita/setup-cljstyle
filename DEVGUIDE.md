# Development Guide

## Requirements

- [Node.js](https://nodejs.org)
- [pnpm](https://pnpm.io)

## Install dependencies

```bash
pnpm install
```

## Build

```bash
pnpm build
```

watch mode:

```bash
pnpm dev
```

## Lint

```bash
pnpm lint
```

## Format

```bash
pnpm format:check
```

or

```bash
pnpm format:write
```

## ビジネスロジック

指定されたバージョンまたは最新バージョンの cljstyle バイナリをダウンロードしてきて適切に配置し、PATH を通す。

## 言葉の定義

- モデル：問題解決のために、物事の特定の側面を抽象化したもの
- ドメイン：ソフトウェアで問題解決しようとする対象
- モデルの分類 (明確に区別すべきであり、先にドメインモデルを作る)
    - ドメインモデル：ドメインの問題を解決するためのモデル
    - データモデル：データベースで何かを永続化するためのモデル

## ドメイン

GitHub Actions にホストされているランナーでは、cljstyle が使えない。
使えるようにしたい。

## ドメインモデリング

- ユースケース図
- ドメインモデル図によるモデリング

- ユースケース図
    - ユーザとアプリの相互作用を定義する
    - 一般的な UML のものと同じ
    - 次に続くドメインモデリングの範囲も決める

- ユースケース
    - 「cljstyle のバージョン」「checkを行うかどうか」を与えて実行を開始する
    - 実行を中断する

## やっていること

- GitHub Actions から ``token``, ``cljstyle-version`` input を取得する
- ``cljstyle-version`` input が指定されていない場合、 GitHub REST API 経由で cljstyle の最新バージョンを取得する
- 環境ごとに、cljstyle の圧縮ファイルを GitHub Releases からダウンロードし、解凍後した後適切な場所に cljstyle のバイナリを配置する

## テスト内容

- ``cljstyle-version`` のバリデーション
