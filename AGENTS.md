# Unison

Parent repository for the Unison tools. Each project is a git submodule with its own README.md and AGENTS.md:
`unison-components`, `unison-plugin`, `unison-playground-web`, `unison-playground-expo` and `unison-website`.
`unison-plugin` contains a nested `unison-components` submodule; it is never edited by hand. The playgrounds depend on
the `unison-components` npm package instead, so they work as standalone clones; the playground sync scripts build the
library and copy it over the installed package to try unreleased changes.

## Commands

The root has two scripts, both run from the repository root:

- `./all-dev.sh` - stops whatever its last run started, then runs every watcher plus the web playground, Expo
  playground and website dev servers in parallel until Ctrl+C, logging their PIDs to `.all-dev.pids` (gitignored) so
  the next run can stop them. Long-running; run it in the background. It refuses to start while a submodule is not
  checked out (`git submodule update --init --recursive`).
- `./website-deploy.sh` - runs `unison-website`'s `bun run deploy` (`scripts/deploy.ts`): bakes the site and the
  playground's one-shot pages, then `firebase deploy` to eject.io and cllp-se; publishes live, only run when asked. It
  refuses to run while `unison-website` or `unison-playground-web` is not checked out or doesn't include the commit
  the root records (`git submodule update --init --recursive --merge`), so a stale checkout never publishes an older
  page.

Every other command is a script in a submodule's `package.json`, documented in that submodule's README.md and
AGENTS.md. Run it inside the submodule, or from the root with `bun run --cwd <submodule> <script>`; extra arguments are
passed through. The ones that work across submodules:

- `unison-components`: `components:sync-manual:plugin` / `components:sync-watch:plugin` rsync the library into
  `unison-plugin/unison-components`; `components:sync-manual:playground-web` / `components:sync-watch:playground-web`
  build it and rsync `build/` and `package.json` into `unison-playground-web/node_modules/unison-components`
  (`bun install` there restores the published package); `components:sync-manual:playground-expo` /
  `components:sync-watch:playground-expo` do the same for `unison-playground-expo`. `generate:tokens` and
  `generate:tailwind` (each with a `:watch` variant) regenerate `dist/design-tokens.ts` and `dist/tailwind.css`.
- `unison-plugin`: `plugin:build` builds into the tracked `dist/`; `plugin:watch` rebuilds on every `src/` change.
- `unison-playground-web`: `bake` is the static export into `out/` that `./website-deploy.sh` publishes.

Each submodule also has `lint` (Biome check), `format` (Biome format) and `typecheck` (`tsc --noEmit`).

The manual syncs delete files in the target that the library no longer has; preview with
`bun run --cwd unison-components components:sync-manual:<target> --dry-run`. Watch scripts never exit on their own;
run them in the background.
