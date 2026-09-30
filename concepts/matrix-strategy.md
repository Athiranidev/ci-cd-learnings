# GitHub Actions Matrix Strategy

## What is Matrix Strategy?

Matrix Strategy is a GitHub Actions feature that allows the same job to run multiple times with different values.

Instead of creating separate jobs for each supported version or configuration, we define the values once in a matrix.

Example:

    strategy:
      matrix:
        python-version: ["3.11", "3.12", "3.13"]

GitHub Actions creates separate executions of the same job:

    test (3.11)
    test (3.12)
    test (3.13)

## Why use Matrix Strategy?

Matrix is useful when an application intentionally supports multiple versions, environments, operating systems, or configurations.

Examples:

- Multiple Python versions
- Multiple Node.js versions
- Different operating systems
- Different database versions
- Different configuration combinations

The purpose is compatibility testing across the variants that the project intentionally supports.

Matrix does NOT mean that every project must support multiple versions.

If a Dockerized application deliberately supports only Python 3.12, there may be no reason to test Python 3.11 and 3.13.

## Matrix vs Docker

Docker and Matrix solve different problems.

Docker:

    Application
        +
    Runtime
        +
    Dependencies
        ↓
    Docker image
        ↓
    Consistent, reproducible environment

Matrix:

    Same job
        ↓
    Different supported values
        ↓
    Test each variation

Mental model:

    Docker → defines and packages the runtime environment.

    Matrix → tests the different environments or configurations
              that the project intentionally supports.

## Basic Matrix Structure

    jobs:
      test:
        runs-on: ubuntu-latest

        strategy:
          matrix:
            python-version: ["3.11", "3.12", "3.13"]

The matrix defines three values for `python-version`.

The matrix value can be used with:

    ${{ matrix.python-version }}

For example:

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: ${{ matrix.python-version }}

This causes the same job to use:

    Python 3.11
    Python 3.12
    Python 3.13

## Matrix and Repeated Steps

We only write the test step once:

    - name: Run tests
      run: pytest

GitHub Actions executes that same step for every matrix value.

Conceptually:

    Python 3.11 → pytest
    Python 3.12 → pytest
    Python 3.13 → pytest

This avoids manually creating separate jobs with duplicated workflow configuration.

## Parallel Matrix Execution

Independent matrix executions can run in parallel.

    test
      │
      ├── Python 3.11 → pytest
      ├── Python 3.12 → pytest
      └── Python 3.13 → pytest

Each matrix execution can run on its own GitHub-hosted runner.

Parallel does not guarantee that every execution starts at exactly the same second. It means the independent executions can run concurrently instead of waiting for one another.

## Matrix with Multiple Jobs

A matrix applies to the entire job where it is defined.

If Docker build and push steps are placed inside the matrix job, they would also run once for every matrix value.

For example:

    Python 3.11 → test → Docker build → push
    Python 3.12 → test → Docker build → push
    Python 3.13 → test → Docker build → push

This can cause unnecessary repeated builds and pushes.

A better design is to separate testing and building:

    test job
      ├── Python 3.11 → test
      ├── Python 3.12 → test
      └── Python 3.13 → test
                ↓
             all pass
                ↓
           build job
                ↓
           Docker build
                ↓
           Docker push

## `needs`

The build job can depend on the matrix test job:

    build:
      needs: test

`needs: test` means the build job waits for the test job to successfully complete.

If any matrix execution fails:

    Python 3.11 → PASS
    Python 3.12 → FAIL
    Python 3.13 → PASS

    ↓

    build does not proceed normally.

If all matrix executions pass:

    Python 3.11 → PASS
    Python 3.12 → PASS
    Python 3.13 → PASS

    ↓

    build
    ↓
    Docker push

## Jobs Have Separate Runners

The `test` and `build` jobs run in separate job environments.

Therefore, `build` needs its own checkout:

    test job
      ↓
    Runner A
      ↓
    checkout repository
      ↓
    run tests

    build job
      ↓
    Runner B
      ↓
    checkout repository
      ↓
    build Docker image

`needs` controls job dependency and execution order. It does not share the filesystem between jobs.

## Practical Implementation

Our CI workflow was changed to test three Python versions:

    strategy:
      matrix:
        python-version: ["3.11", "3.12", "3.13"]

The Python setup uses:

    python-version: ${{ matrix.python-version }}

The test job runs:

    Python 3.11 → pytest
    Python 3.12 → pytest
    Python 3.13 → pytest

Docker build and push were moved to a separate `build` job:

    build:
      needs: test

This prevents Docker build and push from being repeated for every Python version.

## Practical Result

GitHub Actions successfully displayed:

    test (3.11) ✓
    test (3.12) ✓
    test (3.13) ✓
    build ✓

This verified that:

- The matrix created separate Python-version test executions.
- The same test job was reused for each version.
- Matrix executions could run independently/parallel.
- The Docker build job ran separately.
- `needs: test` made the build depend on successful testing.
- Docker build/push was not unnecessarily repeated for every matrix value.

## Core Mental Model

    Matrix Strategy
          ↓
    Same job definition
          ↓
    Different values
          ↓
    Multiple job executions
          ↓
    Compatibility testing
          ↓
    Successful validation
          ↓
    Dependent build/deployment job