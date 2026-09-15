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
- You may need to describe the environment in which the issue occurs.

## How to contribute (Pull Requests)

### Write the code you want to change

Here's the process for contributing to the project:

1. Clone the project (or rebase to the latest commit in the main branch)
2. Install the dependencies with `npm install`, and the browser the tests run in with `npx playwright install chromium`
3. Set up ESLint and Prettier in your editor. CI runs `npm run lint`, `npx prettier --check .` and `npm run typecheck`, so run them before you push
4. Write the code that needs to be fixed
5. Update the documentation under `docs/` in every locale. The English and Korean pages mirror each other, with the same headings, demos and examples, and a changed prop is updated in `docs/.vitepress/data/props.ts` in both languages
6. Add or change the tests under `test/` in the same commit as the code they cover, and run `npm test` to confirm the whole suite passes

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

### Create a pull request

When creating a pull request, keep the following in mind:

- Include a specific description of what the modification is, why it needs to be made, and how it works.
- Check to see if there are duplicate pull requests.
- Please use English in all content.

Typically, a project maintainer will review and test your code before merging it into the project. This process can take some time, and they may ask you for further edits or clarifications in the comments.
