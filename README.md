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

The root has two scripts:

- `./all-dev.sh` - stop whatever its last run started, then run every watcher plus the web playground, Expo playground
  and website dev servers in parallel, each output line prefixed with its name, until Ctrl+C. It logs their PIDs to
  `.all-dev.pids`, so the next run stops them even from another terminal. The two Next.js servers share port 3000 by
  default, so whichever starts second moves to 3001.
- `./website-deploy.sh` - run `unison-website`'s `bun run deploy`: bake the site, bake the web playground's one-shot
  pages into `dist/one-shot`, copy `dist/` into the eject.io and cllp-se hosting folders, then run `firebase deploy` in
  each. This publishes the live site.

Every other command is a script in a submodule's `package.json`. Run it inside that submodule, or from the root with
`bun run --cwd <submodule> <script>`. Extra arguments are passed through, e.g.
`bun run --cwd unison-components components:sync-manual:plugin --dry-run`.

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
- `bun run lint` - Biome check.
- `bun run format` - Biome format, writing changes.
- `bun run typecheck` - `tsc --noEmit`.
- `bun run generate:tokens` - regenerate `dist/design-tokens.ts` from `dist/design-tokens.json` and
  `dist/motion-tokens.css`. Commit the result.
- `bun run generate:tokens:watch` - regenerate it whenever `dist/design-tokens.json`, `dist/motion-tokens.css` or its
  generator changes (long-running).
- `bun run generate:tailwind` - regenerate `dist/tailwind.css` from the design tokens and `dist/motion-tokens.css`.
  Commit the result.
- `bun run generate:tailwind:watch` - regenerate it whenever `maps/`, `dist/design-tokens.ts`, `dist/motion-tokens.css`
  or its generator changes (long-running).

### Plugin (`unison-plugin`)

- `bun run plugin:build` - build the plugin into `dist/` (bundle plus static files). Use before loading the plugin in
  Figma. `dist/` is tracked, so this changes committed files.
- `bun run plugin:build:typescript` - only bundle `src/index.ts` into `dist/index.js` with esbuild.
- `bun run plugin:build:files` - only copy `manifest.json`, `index.html` and `placeholder.js` into `dist/`.
- `bun run plugin:watch` - build once, then rebuild whenever `src/` changes.
- `bun run lint` - Biome check.
- `bun run format` - Biome format, writing changes.
- `bun run typecheck` - `tsc --noEmit`.

### Web playground (`unison-playground-web`)

- `bun run dev` - Next.js dev server (long-running). Use while trying components in the browser.
- `bun run build` - production build with `next build`.
- `bun run start` - serve the production build (long-running). Run `build` first.
- `bun run bake` - static export into `out/`, served from `/unison/one-shot`; `./website-deploy.sh` runs it and
  publishes the one-shot pages from it.
- `bun run lint` - Biome check.
- `bun run format` - Biome format, writing changes.
- `bun run typecheck` - `tsc --noEmit`.

### Expo playground (`unison-playground-expo`)

- `bun run start` - Expo dev server (long-running). Works on Linux, Windows and macOS; open the app in Expo Go on a
  phone by scanning the QR code.
- `bun run android` - dev server that also opens the Android emulator.
- `bun run ios` - dev server that also opens the iOS simulator. The simulator and native iOS builds need macOS with
  Xcode, or EAS Build from any OS.
- `bun run lint` - Biome check.
- `bun run format` - Biome format, writing changes.
- `bun run typecheck` - `tsc --noEmit`.

### Website (`unison-website`)

- `bun run dev` - Next.js dev server (long-running). Use while editing the landing page.
- `bun run build` - production build with `next build`.
- `bun run start` - serve the production build (long-running). Run `build` first.
- `bun run lint` - Biome check.
- `bun run format` - Biome format, writing changes.
- `bun run typecheck` - `tsc --noEmit`.
- `bun run bake` - export the site and fold it into one self-contained `dist/index.html`.
- `bun run deploy` - what `./website-deploy.sh` runs. This publishes the live site.
