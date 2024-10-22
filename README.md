# Lambda EFS SQLite

## Motivation

- API Gateway + Lambda の構成で RDB を使いたいが、RDS は高いので EFS で SQLite のファイルを永続化したい
- 複数言語で API を実装して今後の参考にしたい

## Architecture

> TODO

## Loadmap

- Node.js (TS + Drizzle + Hono) の API を追加
- Go (fiber + sqlc?) の API を追加
