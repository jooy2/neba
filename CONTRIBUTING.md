# Contributing to Neba

Thank you for contributing to the project. Your contributions help make it better.

This project adheres to the [Contributor Covenant](CODE_OF_CONDUCT.md) code of conduct, version 2.1. Your contribution implies that you have read and agree to this policy. Any behavior that undermines the quality of the project community, including this policy, will be warned or restricted by the maintainers.

## Issues

Issues can be created on the following page: https://github.com/jooy2/neba/issues

Alternatively, you can reach the maintainers at https://cdget.com/contact. However, we prefer to track progress via GitHub Issues.

When creating an issue, keep the following in mind:

- Please specify the correct category selection based on the format of the issue (e.g., bug report, feature request).
- Check to see if there are duplicate issues.
- Describe in detail what is happening and what needs to be fixed. You may need additional materials such as images or video.
- Use appropriate keyword titles to make it easy for others to search and understand.
- Please use English in all content.
- Name the package and its version: for `neba` on npm, the React version and the browser you saw it in; for `neba` on pub.dev, the Flutter version and the platform.

## Where things live

The repository holds one design language and the things built out of it:

| Path | What it is | How it is run |
| --- | --- | --- |
| `packages/react` | The npm package, `neba` | `cd packages/react && npm install`, then `npm test`, `npm run lint`, `npm run build` |
| `packages/flutter` | The pub.dev package, `neba` | `cd packages/flutter && flutter pub get`, then `flutter test`, `flutter analyze` |
| `docs` | The documentation site, shared by both | `cd docs && npm install`, then `npm run dev` |
| `examples/flutter` | A sample app for iOS, iPadOS and Android | `cd examples/flutter && flutter test`; [examples/README.md](examples/README.md) says how to run it on a device |

There is no install at the repository root, and no root `package.json`. Each of these is entered and run on its own. Node.js 22.12 or later is needed for the React package and the site, and Flutter 3.41 or later for the Flutter package.

A few things that are easy to trip over:

- The site renders the React components from `packages/react/src`, so a component edit shows up in `npm run dev` without a rebuild, but the site needs `packages/react/node_modules` to resolve the library's own imports. Run `npm install` in `packages/react` first.
- The Flutter tokens are the React stylesheet's, computed in Dart. A change to a value in `packages/react/src/styles.css` is a change to `packages/flutter/lib/src/theme/tokens.dart` in the same pull request, and `packages/flutter/test/theme/tokens_parity_test.dart` fails until both say the same thing.
- `packages/flutter/lib/neba.dart` and `packages/flutter/example/lib/demos/registry.dart` are generated. After adding a widget or a demo, run `dart run tool/generate.dart` in `packages/flutter`.
- The Flutter port is in progress, and [TODO.md](TODO.md) is its roadmap.

## How to contribute (Pull Requests)

### Write the code you want to change

Here's the process for contributing to the project:

1. Clone the project (or rebase to the latest commit in the main branch)
2. Install the dependencies of the part you are changing. For the React package, `npm install` in `packages/react` and the browser the tests run in with `npx playwright install chromium`; for the Flutter package, `flutter pub get` in `packages/flutter`
3. Set up the formatter in your editor. For the React package and the site, CI runs `npm run lint`, `npx prettier --check .` and `npm run typecheck`, and after `npm run build` it runs `npm run size` and `npm run compat`; for the Flutter package and the apps, `flutter analyze`, `dart format --set-exit-if-changed` and `flutter test`. Run them before you push
4. Write the code that needs to be fixed
5. Update the documentation under `docs/` in every locale. The English and Korean pages mirror each other, with the same headings, demos and examples, and a changed prop is updated in `docs/.vitepress/data/props.ts` in both languages. A new component also needs its demos under `docs/.vitepress/demos/`, a card in `demos/catalog/all.tsx`, a place on the sample screen in `demos/showcase/app.tsx` and a line in `docs/public/llms.txt`
6. Add or change the tests in the same commit as the code they cover, under the package's own `test/`, and run the package's whole suite to confirm it passes

### Write a commit message

Commit messages follow these rules:

- Write in English.
- Use the ` symbol to name functions, variables, or folders and files.
- Use a format like `xxx: message (fixes #1)`. The content in parentheses is optional.
- The message includes a summary of what was modified.
- It's a good idea to separate multiple modifications into their own commit messages.

Include a tag at the beginning of the commit message, and separate the tag from the message with `: `.

Tags conform to the ["Udacity Git Commit Message Style Guide"](https://udacity.github.io/git-styleguide).

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Changes to documentation
- `style`: Formatting, missing semicolons, etc.; no code change
- `refactor`: Refactoring production code
- `test`: Adding tests, refactoring test; no production code change
- `chore`: Updating build tasks, package manager configs, etc.; no production code change

Informal tags:

- `package`: Modifications to package settings, modules, or GitHub projects
- `typo`: Fix typos

This repository holds two packages, so a tag is preceded by the codebase the change belongs to:

- `[javascript]` for a change to `packages/react` alone, as in `[javascript] fix: keep the focus on the trigger after a picker is cleared`
- `[dart]` for a change to `packages/flutter` or the Flutter apps alone, as in `[dart] feat: port NebaButton to Flutter, with its tests, demos, docs and props table`
- No prefix for a change that touches both packages, or neither, as in `docs: say on the tabs page which panels are rendered`

Keep one component to one commit, so that a later reader can find, read or revert the one they care about on its own.

### Create a pull request

When creating a pull request, keep the following in mind:

- Include a specific description of what the modification is, why it needs to be made, and how it works.
- Check to see if there are duplicate pull requests.
- Please use English in all content.

Typically, a project maintainer will review and test your code before merging it into the project. This process can take some time, and they may ask you for further edits or clarifications in the comments.
