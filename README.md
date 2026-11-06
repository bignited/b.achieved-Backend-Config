# b.achieved-Backend-Config

Shared configuration for the b.achieved repositories:

- **`specializations.yaml`**: every specialization and sub-specialization, in one place.
- **`feature-flags/`**: feature flags per environment.

## Specializations

To add or change a specialization or a sub-specialization, edit **`specializations.yaml`** only.
The comments at the top of that file explain every field. The frontend (names, descriptions,
colours, planet looks and the specialization picker) and the Playwright tests read it directly.

The backend keeps no list: a user may choose `GLOBAL` or any specialization that appears on an
uploaded seal. So a new specialization becomes available as soon as the skill matrix has seals for
it, and an entry here only decides how it looks and reads.

# Feature flags

## Where the flags live

```
feature-flags/
  development.yaml
  preproduction.yaml
  production.yaml
```

Each file uses the same format the applications read:

```yaml
features:
  feature.GemButton: true
```

To turn a flag on or off for one environment, change it in that environment's file and commit.
You no longer need to edit flags before each deploy: every build picks the file for the
environment it deploys to.

## Adding or removing a flag

Add (or remove) the flag in **all three** files. The build fails when the files don't list the
same flags, so a flag can't silently be missing in one environment.

## How the builds use it

The frontend and backend buildspecs clone this repository and run:

```bash
bash b.achieved-Backend-Config/select-feature-flags.sh "$envType" <destination>
```

`$envType` is `development`, `preproduction` or `production`. The script checks the files and
copies the matching one to `<destination>`. The build fails on an unknown environment or a
missing file instead of deploying without flags.

You can run the same command locally, for example to put the development flags into a local
backend build.

## Old `feature-flags.yaml`

The single `feature-flags.yaml` at the root is only kept for branches whose buildspec doesn't
use `select-feature-flags.sh` yet (for example `preprod` and `release` before they receive the
new buildspec). Remove it once every deployed branch uses the per-environment files.
