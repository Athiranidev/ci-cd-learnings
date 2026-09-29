# Branch Protection & Required Status Checks

## 1. What is Branch Protection?

Branch protection is a GitHub feature that adds rules to important branches such as `main`.

The purpose is to control how changes can be added to a protected branch.

For example:

    Feature branch
          ↓
    Pull Request
          ↓
    CI validation
          ↓
    CI passes
          ↓
    Merge
          ↓
        main

Instead of allowing changes to be added directly to `main`, GitHub can require specific conditions to be satisfied first.

---

## 2. Why do we need Branch Protection?

Without branch protection, a developer with push access could potentially push directly to `main`.

For example:

    git checkout main
    git add .
    git commit -m "changes"
    git push

This could put untested changes directly into the main branch.

Branch protection helps keep `main` protected by enforcing rules before changes are accepted.

Core idea:

    Validate changes before they enter main.

---

## 3. Required Status Checks

A status check is the result of an automated check such as a GitHub Actions job.

Our workflow contains:

    jobs:
      test:

GitHub displays this job as:

    test

The job runs our CI pipeline.

If the job succeeds:

    test → Successful

If the job fails:

    test → Failed

---

## 4. Require Status Checks to Pass

We enabled:

    Require status checks to pass

Then selected:

    test — GitHub Actions

This means the `test` CI job must successfully complete before the protected `main` branch can be updated through the protected workflow.

The relationship is:

    GitHub Actions
          ↓
    Run CI
          ↓
    Produce status
          ↓
    Branch Protection
          ↓
    Check required status
          ↓
    Allow or block merge

---

## 5. Require Pull Request Before Merging

We also enabled:

    Require a pull request before merging

This means changes must come through a Pull Request instead of being directly pushed into `main`.

The flow becomes:

    Feature branch
          ↓
    Push to GitHub
          ↓
    Pull Request → main
          ↓
    CI
          ↓
    Required check
          ↓
    Merge
          ↓
    main

---

## 6. Ruleset Configuration

We created a GitHub ruleset named:

    Protect main

Configuration:

    Enforcement status:
        Active

    Target branch:
        main

Rules enabled:

    Require a pull request before merging
    Require status checks to pass
        └── test — GitHub Actions
    Restrict deletions
    Block force pushes

Required approvals were left at:

    0

For this exercise, the focus was automated CI validation rather than mandatory human review.

---

## 7. Practical Test

We created a temporary branch:

    test-protection

We intentionally changed the CI workflow from:

    - name: Run tests
      run: pytest

to:

    - name: Run tests
      run: |
        pytest
        exit 1

`pytest` itself passed, but `exit 1` deliberately made the GitHub Actions step fail.

We committed and pushed the branch:

    test-protection → GitHub

Then created:

    Pull Request: test-protection → main

---

## 8. Failed CI Blocks the Merge

The Pull Request showed:

    CI / test (pull_request) → Failed
    Required

Because the required status check failed, GitHub did not allow the Pull Request to be merged.

The flow was:

    Pull Request
          ↓
    CI fails
          ↓
    Required check fails
          ↓
    Merge blocked

This demonstrated that branch protection was actually enforcing the CI result.

---

## 9. Fixing the CI

We changed the test step back to:

    - name: Run tests
      run: pytest

Then committed and pushed the fix to the same `test-protection` branch.

The existing Pull Request was automatically updated.

GitHub ran CI again:

    CI / test (pull_request)
          ↓
       Successful

The required check then passed.

---

## 10. Successful Merge

After the CI check passed, GitHub showed:

    All checks have passed
    CI / test (pull_request) → Successful
    Required
    No conflicts with base branch

The Merge Pull Request button became available.

We merged:

    test-protection → main

GitHub then closed the Pull Request and deleted the remote `test-protection` branch.

---

## 11. Updating Local main

After the merge, we switched back to local `main`:

    git checkout main

Then updated it from GitHub:

    git pull origin main

Git reported:

    Fast-forward

Our local `main` was now synchronized with `origin/main`.

---

## 12. Complete Flow

The practical flow we verified was:

    Feature branch
          ↓
    Push branch to GitHub
          ↓
    Pull Request → main
          ↓
    GitHub Actions CI
          ↓
    ┌──────────────────────┐
    │ Required CI check    │
    └──────────────────────┘
          ↓
       ┌───────┐
       │       │
      PASS    FAIL
       │       │
       ↓       ↓
    Merge    Block
    allowed  merge
       │
       ↓
      main

---

## 13. Core Mental Model

    Pull Request
        = request to merge changes

    CI
        = automated validation

    Status check
        = result of the CI job

    Branch protection
        = rules controlling changes to a protected branch

    Required status check
        = a rule requiring a specific CI check to pass

The main principle:

    Feature branches can contain changes being developed.

    main is protected.

    Changes must pass the required validation before
    they can be merged into main.