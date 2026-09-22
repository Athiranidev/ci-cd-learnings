# Python Dependency Installation in CI

## Project Structure

ci-cd-learnings/
├── .github/
│   └── workflows/
│       └── ci.yml
├── app.py
├── requirements.txt
├── test_app.py
├── test.sh
└── .gitignore


## Python Project

app.py:

def add(a, b):
    return a + b


test_app.py:

from app import add

def test_add():
    assert add(2, 3) == 5


requirements.txt:

pytest


## Virtual Environment

Ubuntu manages the system Python environment separately. Because of PEP 668, installing Python packages directly into the system environment with pip can be blocked.

Create a project-specific virtual environment:

python3 -m venv .venv

Activate it:

source .venv/bin/activate

Install project dependencies:

pip install -r requirements.txt

The virtual environment keeps project dependencies separate from the system Python.

The .venv directory should not be committed to Git.

.gitignore:

.venv/
__pycache__/


## GitHub Actions CI Workflow

name: CI

on:
  push:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Check environment
        run: |
          echo "Checking runner environment..."
          pwd
          ls -la

      - name: Install dependencies
        run: python3 -m pip install -r requirements.txt

      - name: Run tests
        run: pytest

      - name: Build
        run: echo "Build started"


## How the CI Runner Gets Dependencies

A GitHub Actions runner starts with a fresh environment.

The runner does not automatically know about the project's Python dependencies.

The workflow explicitly installs them from requirements.txt.

Flow:

GitHub repository
        ↓
Checkout repository
        ↓
requirements.txt
        ↓
python3 -m pip install -r requirements.txt
        ↓
Dependencies installed
        ↓
pytest
        ↓
Build


## Complete CI Flow

Developer changes code
        ↓
git add
        ↓
git commit
        ↓
git push
        ↓
GitHub Actions starts runner
        ↓
Checkout repository
        ↓
Check environment
        ↓
Install dependencies
        ↓
Run tests
        ↓
If tests pass
        ↓
Build


## Failure Example

When requirements.txt was not committed, GitHub Actions failed with:

ERROR: Could not open requirements file:
[Errno 2] No such file or directory: 'requirements.txt'

Reason:

Local machine
    ↓
requirements.txt exists

GitHub repository
    ↓
requirements.txt was not committed

GitHub runner
    ↓
requirements.txt does not exist

After committing and pushing requirements.txt, the pipeline succeeded.


## Successful CI Result

Checkout code        ✅
Check environment    ✅
Install dependencies ✅
Run tests             ✅
1 passed
Build                 ✅


## Important Lessons

requirements.txt
    → Declares the Python dependencies required by the project.

pip install -r requirements.txt
    → Installs the dependencies declared in requirements.txt.

GitHub Actions runner
    → Fresh environment where the CI job executes.

pytest
    → Runs the automated Python tests.

Exit code 0
    → Normally means the command succeeded.

Non-zero exit code
    → Normally means the command failed.

Steps execute sequentially by default.

If dependency installation fails:

Install dependencies ❌
Run tests             ⏭ skipped
Build                 ⏭ skipped

If tests fail:

Install dependencies ✅
Run tests             ❌
Build                 ⏭ skipped

If tests pass:

Install dependencies ✅
Run tests             ✅
Build                 ✅


## Core Mental Model

Project dependency
        ↓
requirements.txt
        ↓
Git commit + push
        ↓
GitHub repository
        ↓
GitHub Actions checkout
        ↓
pip install
        ↓
Dependencies available on runner
        ↓
pytest
        ↓
Build


## Key Principle

The CI runner starts with a fresh environment, so the workflow must explicitly install the project's dependencies before running tests.