<!--
Thank you for contributing to the project. Your contribution will be reviewed and approved after appropriate review.

Please read the caveats below to ensure a fast merge.
-->

## Pull request checklist

You should familiarize yourself with the files `README.md`, `CONTRIBUTING.md`, and `CODE_OF_CONDUCT.md` in the root of your project.

- If an issue has been created for this, add `(fixes #{ISSUE_NUMBER})` to the end of the commit description. In `{ISSUE_NUMBER}`, please include the relevant issue number.
- If the change is visible to someone using the library, update its documentation in both `docs/en` and `docs/ko`, and its rows in `docs/.vitepress/data/props.ts`.
- Add or update the tests under `test/` in the same commit as the change, and confirm that `npm test`, `npm run lint` and `npm run typecheck` pass.
- If this PR is not yet complete, keep the PR in draft status. If it's no longer valid, close the PR with an explanation.

<!--
Below is a template for describing this PR. It's not required, so please delete the content below if you don't need it.
-->

### What did you change?

### Why did you make the change?

### How does this work?
