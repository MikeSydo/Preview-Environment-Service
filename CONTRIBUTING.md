# Contributing

Thanks for your interest in improving Preview Environment Platform.

## How to contribute

1. Create a feature branch.
2. Make focused changes.
3. Update docs when behavior changes.
4. Test locally.
5. Open a pull request.

## Branch naming

Examples:

- `feature/add-ttl-cleanup`
- `bugfix/preview-comment`
- `docs/rewrite-readme`

## Pull request expectations

Your PR should include:

- a clear title,
- a short description,
- testing notes,
- documentation updates if needed.

## Preview label rule

If your change should create or test a live preview environment, add the `preview` label to the PR.

That label is what tells Argo CD to provision the environment.

## Before opening a PR

Check that:

- GitHub workflows are valid,
- Helm templates render correctly,
- Argo CD manifests are updated if needed,
- documentation matches the implementation.

Example:

```bash
helm lint helm/preview-app
helm template preview-app helm/preview-app
```

## Issues

Use the issue templates for bugs and feature requests.
