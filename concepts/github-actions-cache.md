# GitHub Actions Dependency Caching

## Why caching is used

A GitHub Actions runner is a fresh environment for workflow runs. Without caching, dependencies may need to be downloaded again on every run.

Caching stores reusable dependency data so later workflow runs can restore it instead of downloading everything again.

Caching is mainly a **performance optimization**. The CI pipeline should still work when no cache exists.

## Python pip caching

Our project uses Python dependencies from:

    requirements.txt

We added this step before installing dependencies:

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.12'
        cache: 'pip'

### Meaning

    actions/setup-python@v5
        ↓
    Sets up Python on the GitHub Actions runner
        ↓
    cache: 'pip'
        ↓
    Enables caching for pip dependencies

The dependency installation step remains:

    - name: Install dependencies
      run: python3 -m pip install -r requirements.txt

## What we observed

### First CI run

There was no existing cache.

GitHub Actions showed:

    pip cache is not found

This is a **cache miss**.

Flow:

    CI run
      ↓
    Set up Python
      ↓
    Cache not found
      ↓
    Install dependencies
      ↓
    Tests
      ↓
    Cache becomes available for later runs

### Second CI run

The same workflow was run again.

GitHub Actions showed:

    Cache hit for: setup-python-Linux-x64-...

    Cache restored successfully

This is a **cache hit**.

Flow:

    CI run
      ↓
    Set up Python
      ↓
    Existing cache found
      ↓
    Cache restored
      ↓
    Install dependencies
      ↓
    Tests

## Cache does not mean skipping installation

We still run:

    python3 -m pip install -r requirements.txt

The cache provides previously downloaded package data that pip can reuse.

The cache therefore reduces repeated downloading rather than replacing dependency installation entirely.

## Cache vs Artifact

### Cache

    Cache
      ↓
    Reusable data for future workflow runs
      ↓
    Main purpose: speed up CI

### Artifact

    Artifact
      ↓
    Files produced by a workflow
      ↓
    Main purpose: preserve/download workflow outputs

Cache and artifacts solve different problems.

## Our CI flow

    Push / Pull Request
          ↓
    Checkout code
          ↓
    Check environment
          ↓
    Check secret
          ↓
    Set up Python + restore pip cache
          ↓
    Install dependencies
          ↓
    Run tests
          ↓
    Build Docker image
          ↓
    Login to Docker Hub
          ↓
    Push Docker image

## Key mental model

    First run
        ↓
    Cache miss
        ↓
    Download dependencies
        ↓
    Cache becomes available

    Next run
        ↓
    Cache hit
        ↓
    Restore cached dependency data
        ↓
    Less repeated downloading

## Important point

Caching is an optimization, not a requirement for CI correctness.

If the cache is unavailable, the workflow should still be able to install the dependencies and run successfully.