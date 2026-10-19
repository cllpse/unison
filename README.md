# Unison

Tools for generating React Native component code from Figma. This repository holds the Unison projects as git
submodules:

- `unison-components` - the component library, whose props mirror Figma properties as boolean flags
- `unison-plugin` - the Figma plugin that generates component code for `unison-components`
- `unison-playground-web` - a small site for trying out `unison-components`
- `unison-playground-expo` - a small Expo app for trying out `unison-components` on iOS and Android
- `unison-website` - the site pitching the Unison tooling

`unison-plugin`, `unison-playground-web` and `unison-playground-expo` each carry their own nested copy of
`unison-components`. The sync scripts below keep the plugin and playground copies up to date; the Expo playground's
copy is a pinned submodule you bump by hand.

## Setup

```sh
git submodule update --init --recursive
```

Then run `bun install` inside each submodule you work on. Bun is the package manager; the root has no dependencies
of its own.

## Commands

Every root script runs the script of the same name inside its submodule (`bun run --cwd <submodule> <script>`), so
it behaves exactly as if you ran it from that folder. Extra arguments are passed through, e.g.
`bun run components:sync-manual:plugin -- --dry-run`.

### Components (`unison-components`)

- `bun run components:sync-manual:plugin` - copy `dist/` and `src/` into `unison-plugin/unison-components`
  once, deleting files that no longer exist. Use before building the plugin against local component changes.
- `bun run components:sync-watch:plugin` - keep `unison-plugin/unison-components` in sync while you edit. Use while
  working on components and the plugin together.
- `bun run components:sync-manual:playground-web` - the same one-off copy into
  `unison-playground-web/unison-components`.
- `bun run components:sync-watch:playground-web` - the same live sync into `unison-playground-web/unison-components`.
  Use while trying component changes in the playground.
- `bun run components:lint` - Biome check.
- `bun run components:format` - Biome format, writing changes.
- `bun run components:typecheck` - `tsc --noEmit`.

### Plugin (`unison-plugin`)

- `bun run plugin:build` - build the plugin into `dist/` (bundle plus static files). Use before loading the plugin in
  Figma. `dist/` is tracked, so this changes committed files.
- `bun run plugin:build:typescript` - only bundle `src/index.ts` into `dist/index.js` with esbuild.
- `bun run plugin:build:files` - only copy `manifest.json`, `index.html` and `placeholder.js` into `dist/`.
- `bun run plugin:watch` - build once, then rebuild whenever `src/` changes.
- `bun run plugin:lint` - Biome check.
- `bun run plugin:format` - Biome format, writing changes.
- `bun run plugin:typecheck` - `tsc --noEmit`.

### Expo playground (`unison-playground-expo`)

- `bun run playground-expo:start` - Expo dev server (long-running). Works on Linux, Windows and macOS; open the app in
  Expo Go on a phone by scanning the QR code.
- `bun run playground-expo:android` - dev server that also opens the Android emulator.
- `bun run playground-expo:ios` - dev server that also opens the iOS simulator. The simulator and native iOS builds
  need macOS with Xcode, or EAS Build from any OS.
- `bun run playground-expo:lint` - Biome check.
- `bun run playground-expo:format` - Biome format, writing changes.
- `bun run playground-expo:typecheck` - `tsc --noEmit`.
