# Pull Request CI

## 1. What is a Pull Request?

A Pull Request (PR) is a request to merge changes from one branch into another branch.

Example:

feature branch → Pull Request → main

A Pull Request itself does not merge the code.

The merge is a separate action.

---

## 2. Pull Request CI

GitHub Actions can run CI when a Pull Request targets a specific branch.

Example:

on:
  pull_request:
    branches:
      - main

This means:

When a Pull Request targeting main is created or updated, the workflow can run.

---

## 3. `on`

The `on` section defines the events that trigger a GitHub Actions workflow.

Example:

on:
  push:
    branches:
      - main

  pull_request:
    branches:
      - main

There are two triggers:

push
→ workflow runs when code is pushed to main

pull_request
→ workflow runs when a Pull Request targeting main is created or updated

---

## 4. `push` vs `pull_request`

`push`:

git push
    ↓
push event
    ↓
GitHub Actions runs

`pull_request`:

feature branch
    ↓
Pull Request → main
    ↓
pull_request event
    ↓
GitHub Actions runs

The `pull_request` trigger does not merge the code into main.

---

## 5. Why Use Pull Request CI?

Pull Request CI checks proposed changes before they are merged into the main branch.

Example:

feature branch
    ↓
Pull Request
    ↓
CI
    ↓
Tests
    ↓
Build
    ↓
Review
    ↓
Merge into main

This helps identify problems before the changes become part of main.

---

## 6. Feature Branch Workflow

A common workflow is:

main
  ↓
create feature branch
  ↓
make changes
  ↓
commit
  ↓
push feature branch
  ↓
create Pull Request
  ↓
CI runs
  ↓
review
  ↓
merge into main

---

## 7. Pull Request Can Have Multiple Commits

A Pull Request can receive multiple commits.

Example:

test-pr
  ↓
Commit 1
  ↓
Pull Request
  ↓
CI runs
  ↓
Commit 2
  ↓
same Pull Request updates
  ↓
CI runs again

A new branch or new Pull Request is not required for every commit.

---

## 8. Practical Example

Created branch:

test-pr

Created first commit:

Test pull request CI

Created Pull Request:

test-pr → main

GitHub Actions ran:

CI / test (pull_request)

The check passed.

Then another commit was added to the same branch:

Update pull request test

The existing Pull Request was updated and GitHub Actions ran again.

Both CI checks passed.

---

## 9. Important Mental Model

Pull Request:

→ Request to merge changes

`pull_request`:

→ GitHub Actions trigger for Pull Request events

CI:

→ Checks the proposed changes

Merge:

→ Actually puts the changes into the target branch

Simple flow:

feature branch
    ↓
Pull Request
    ↓
CI checks
    ↓
Review
    ↓
Merge
    ↓
main

---

## Core Principle

Pull Request CI provides automated verification of changes before they are merged into the main branch.

The Pull Request triggers CI.

The CI checks the changes.

The merge actually puts the changes into main.