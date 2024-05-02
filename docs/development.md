# Development

## Pre-requisites

```sh
npm install
```

## Development

```sh
npm run check && cd example && npm run check
npm run precommit-fix && cd example && npm run precommit-fix
```

## Publish

- Build and preview docs
  - `npm run build -- --docs docs.json`
  - Open https://elm-doc-preview.netlify.app
  - Open Files -> `README.md` and `docs.json` -> review... -> Close Preview
