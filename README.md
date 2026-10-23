# Unison

Tools for generating React Native component code from Figma. This repository holds the Unison projects as git
submodules:

- [unison-components](https://github.com/cllpse/unison-components) - the component library, whose props mirror Figma properties as boolean flags
- [unison-plugin](https://github.com/cllpse/unison-plugin) - the Figma plugin that generates component code for `unison-components`
- [unison-playground-web](https://github.com/cllpse/unison-playground-web) - a small site for trying out `unison-components`
- [unison-playground-expo](https://github.com/cllpse/unison-playground-expo) - a small Expo app for trying out `unison-components` on iOS and Android
- [unison-website](https://github.com/cllpse/unison-website) - the site pitching the Unison tooling

`unison-plugin` carries its own nested copy of `unison-components` as a submodule. The playgrounds depend on the
`unison-components` npm package instead, so each one also works as a standalone clone. The sync scripts below keep the
plugin's copy, and the playgrounds' installed packages, up to date with local library changes.

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

`./run.sh` lists all root scripts and runs the ones you pick: Space to select several in a gum list (fzf or a numbered
menu without gum), Enter to run. Several picks run in parallel with each line prefixed by its script name;
`./run.sh --sequential` runs them one after another instead. Ctrl+C stops them all.
Parallel output keeps the scripts' own colors.

The first two entries are `local:start`, which runs `local:stop` first and then starts every watcher plus
`playground-web:dev` and `playground-expo:start`, logging their PIDs to `.local.pids`, and `local:stop`, which kills the
logged processes from any terminal and then clears the log. They also run directly: `./run.sh local:start` and
`./run.sh local:stop`.

### Components (`unison-components`)

- `bun run components:sync-manual:plugin` - copy `dist/` and `src/` into `unison-plugin/unison-components`
  once, deleting files that no longer exist. Use before building the plugin against local component changes.
- `bun run components:sync-watch:plugin` - keep `unison-plugin/unison-components` in sync while you edit. Use while
  working on components and the plugin together.
- `bun run components:sync-manual:playground-web` - build the library and copy `build/` and `package.json` over the
  installed package in `unison-playground-web/node_modules/unison-components`. Use to try unreleased library changes
  in the playground; `bun install` there puts the published package back.
- `bun run components:sync-watch:playground-web` - the same build and copy on every library change. Use while trying
  component changes in the playground.
- `bun run components:sync-manual:playground-expo` / `components:sync-watch:playground-expo` - the same for
  `unison-playground-expo`.
- `bun run components:lint` - Biome check.
- `bun run components:format` - Biome format, writing changes.
- `bun run components:typecheck` - `tsc --noEmit`.
- `bun run components:generate:tokens` - regenerate `dist/design-tokens.ts` from `dist/design-tokens.json` and `dist/motion-tokens.css`. Commit the result.
- `bun run components:generate:tokens:watch` - regenerate it whenever `dist/design-tokens.json`, `dist/motion-tokens.css` or its generator changes
  (long-running).
- `bun run components:generate:tailwind` - regenerate `dist/tailwind.css` from the design tokens and `dist/motion-tokens.css`. Commit the result.
- `bun run components:generate:tailwind:watch` - regenerate it whenever `maps/`, `dist/design-tokens.ts`, `dist/motion-tokens.css` or its generator changes
  (long-running).

### Plugin (`unison-plugin`)

- `bun run plugin:build` - build the plugin into `dist/` (bundle plus static files). Use before loading the plugin in
  Figma. `dist/` is tracked, so this changes committed files.
- `bun run plugin:build:typescript` - only bundle `src/index.ts` into `dist/index.js` with esbuild.
- `bun run plugin:build:files` - only copy `manifest.json`, `index.html` and `placeholder.js` into `dist/`.
- `bun run plugin:watch` - build once, then rebuild whenever `src/` changes.
- `bun run plugin:lint` - Biome check.
- `bun run plugin:format` - Biome format, writing changes.
- `bun run plugin:typecheck` - `tsc --noEmit`.

### Web playground (`unison-playground-web`)

- `bun run playground-web:dev` - Next.js dev server (long-running). Use while trying components in the browser.
- `bun run playground-web:build` - production build with `next build`.
- `bun run playground-web:start` - serve the production build (long-running). Run `playground-web:build` first.
- `bun run playground-web:bake` - static export into `unison-playground-web/out`, served from `/unison/one-shot`;
  `website:deploy` runs it and publishes the one-shot pages from it.
- `bun run playground-web:lint` - Biome check.
- `bun run playground-web:format` - Biome format, writing changes.
- `bun run playground-web:typecheck` - `tsc --noEmit`.

### Expo playground (`unison-playground-expo`)

- `bun run playground-expo:start` - Expo dev server (long-running). Works on Linux, Windows and macOS; open the app in
  Expo Go on a phone by scanning the QR code.
- `bun run playground-expo:android` - dev server that also opens the Android emulator.
- `bun run playground-expo:ios` - dev server that also opens the iOS simulator. The simulator and native iOS builds
  need macOS with Xcode, or EAS Build from any OS.
- `bun run playground-expo:lint` - Biome check.
- `bun run playground-expo:format` - Biome format, writing changes.
- `bun run playground-expo:typecheck` - `tsc --noEmit`.

### Website (`unison-website`)

- `bun run website:dev` - Next.js dev server (long-running). Use while editing the landing page.
- `bun run website:build` - production build with `next build`.
- `bun run website:start` - serve the production build (long-running). Run `website:build` first.
- `bun run website:lint` - Biome check.
- `bun run website:format` - Biome format, writing changes.
- `bun run website:typecheck` - `tsc --noEmit`.
- `bun run website:bake` - export the site and fold it into one self-contained `dist/index.html`.
- `bun run website:deploy` - bake, bake the web playground's one-shot pages into `dist/one-shot`, copy `dist/` into
  the eject.io and cllp-se hosting folders, then run `firebase deploy` in each. This publishes the live site.
