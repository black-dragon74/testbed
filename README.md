# testbed

A throwaway Go repository used to exercise
[`red-hat-storage/actions/go-patch-version`][action] end to end.

Nothing here is meant to be useful on its own: the module just prints a UUID.
What matters is the shape of the tree, which mirrors the Red Hat Storage repos
the action targets.

## What is being tested

| Thing in this repo | Feature it exercises |
| --- | --- |
| `go.mod` with a `toolchain` directive | `go` directive rewrite, `remove-toolchain` |
| `api/go.mod` | `go-mod-paths: auto` discovering every module |
| `vendor/` in the root module only | `vendor: auto` (vendors root, leaves `api/` alone) |
| `Dockerfile` with `FROM golang:1.23` | `containerfiles: auto` + the `golang:` prefix |
| `Containerfile.rhel` with `go-toolset:1.23` | a second `containerfile-image-prefixes` entry |
| `build.env` | `version-files`, both full and `:minor` mode |
| four branches | per branch specs, release PR titles, skip detection |

## Branches

The branches all start at Go `1.23.0` and each one takes a different path
through the action:

| Branch | Spec | Expected |
| --- | --- | --- |
| `main` | `1.24` | probes the image, bumps to `1.24.x`, PR titled `Bump go from ... to ...` |
| `release-1.0` | `1.25` | probes the image, bumps to `1.25.x`, PR titled `NO-ISSUE: [release-1.0] ...` |
| `release-0.9` | `=1.24.3` | pinned, no image probe at all |
| `release-0.8` | `=1.22.0` | pinned below the current version, status `skipped` |

## Registry

The real workflows probe `brew.registry.redhat.io/rh-osbs/openshift-golang-builder`,
which needs a service account. Here the builder image template points at
`registry.access.redhat.com/ubi9/go-toolset:{tag}` instead, which is public and
carries the same kind of `version` label (`1.24` -> `1.24.6`, `1.25` ->
`1.25.9`). Because `registry-username` is left empty the action skips its
`skopeo login` step, so the whole run needs no registry credentials.

## Running it

The workflow is `workflow_dispatch`, with `dry-run` defaulting to **true**:

```console
gh workflow run go-patch-version.yml -f dry-run=true
gh workflow run go-patch-version.yml -f dry-run=false   # really opens the PRs
```

Branches are pushed straight to this repository (no `fork-repo`), so
`secrets.GITHUB_TOKEN` with `contents: write` and `pull-requests: write` is
enough. That token may not push changes to files under `.github/workflows`; the
bump never touches them, so this only matters if you start editing the workflow
on a bump branch.

[action]: https://github.com/red-hat-storage/actions/tree/main/go-patch-version
