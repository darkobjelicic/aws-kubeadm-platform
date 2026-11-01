# Branching Strategy

GitHub Flow - `main` is always deployable, every change goes through a short-lived branch and a PR.

## Naming convention

- `feat/<name>` - new functionality
- `fix/<name>` - bug fix
- `chore/<name>` - routine maintenance (version bumps, CI config, formatting)
- `refactor/<name>` - restructuring with no behavior change (e.g. extracting shared code)
- `docs/<name>` - documentation-only changes

## Steps

1. Before starting new work, decide: is this a continuation of what I'm already on, or something new? If new, branch from fresh `main` - never keep committing to an already-merged branch.

   ```bash
   git checkout main
   git pull
   git checkout -b <type>/<name>
   ```

2. If you have uncommitted changes and need to switch branches first, shelve them:

   ```bash
   git stash
   git checkout main
   git pull
   git checkout -b <type>/<name>
   git stash pop
   ```

3. Commit, push, open a PR against `main`.

4. After merge, delete the branch - both on GitHub (button on the merged PR) and locally:

   ```bash
   git branch -d <type>/<name>
   git push origin --delete <type>/<name>
   ```

## `main` branch protection

Enforced via a GitHub Ruleset (`protect-main`):

- Require a pull request before merging.
- Require `checks` and `plan` status checks to pass.
- Block force pushes.
- Bypass list: repo owner (for the exception below).

## Known exception: `infrastructure/github-oidc/`

This root has no CI workflow - it's permanently manually-applied by design (see the architecture decisions on why `apply` must never run here through CI). A PR touching only `infrastructure/github-oidc/**` never triggers `checks`/`plan` (the only workflow, `networking.yml`, is path-filtered to `infrastructure/networking/**`), so the required status checks will sit at "Waiting for status to be reported" forever.

For PRs touching only this directory: use the "Merge without waiting for requirements to be met" bypass option as the repo owner. This is the intended path for this one root, not a workaround - it mirrors the same "apply stays manual here" exception at the CI level.
