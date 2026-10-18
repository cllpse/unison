# Unison

Parent repository for the Unison tools. Each project is a git submodule with its own README.md and AGENTS.md:
`unison-components`, `unison-plugin`, `unison-playground-web`, `unison-playground-expo` and `unison-website`.
`unison-plugin`, `unison-playground-web` and `unison-playground-expo` contain a nested `unison-components` submodule; it
is never edited by hand. The sync scripts update the plugin and playground copies; the Expo playground's copy is
bumped as a normal submodule.

## Commands

Run these from the repository root. Each one runs the same-named script inside its submodule via
`bun run --cwd <submodule> <script>`, so the working directory is the submodule. Arguments after `--` are passed
through. See README.md for when to use each.

- `bun run components:sync-manual:plugin` - one-off rsync of `unison-components` into `unison-plugin/unison-components`
- `bun run components:sync-watch:plugin` - watch and sync into `unison-plugin/unison-components` (long-running)
- `bun run components:sync-manual:playground-web` - one-off rsync into `unison-playground-web/unison-components`
- `bun run components:sync-watch:playground-web` - watch and sync into `unison-playground-web/unison-components`
  (long-running)
- `bun run components:lint` / `components:format` / `components:typecheck` - Biome check, Biome format, `tsc --noEmit`
- `bun run plugin:build` - build the plugin into the tracked `dist/`
- `bun run plugin:build:typescript` / `plugin:build:files` - the two halves of `plugin:build`
- `bun run plugin:watch` - rebuild the plugin on every `src/` change (long-running)
- `bun run plugin:lint` / `plugin:format` / `plugin:typecheck` - Biome check, Biome format, `tsc --noEmit`
- `bun run playground-expo:start` - Expo dev server (long-running)
- `bun run playground-expo:android` / `playground-expo:ios` - dev server that opens the emulator or simulator; iOS
  needs macOS (or EAS Build)
- `bun run playground-expo:lint` / `playground-expo:format` / `playground-expo:typecheck` - Biome check, Biome format,
  `tsc --noEmit`

The manual syncs delete files in the target that the library no longer has; preview with
`bun run components:sync-manual:<target> -- --dry-run`. Watch scripts never exit on their own; run them in the
background.
