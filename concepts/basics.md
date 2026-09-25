# CI (Continuous Integration) Fundamentals

## What is CI?

CI stands for Continuous Integration.

Continuous Integration is the practice of frequently integrating code changes into a shared repository and automatically validating those changes through an automated pipeline.

The main purpose of CI is to detect problems early by automatically checking the code whenever changes are integrated.

## CI Abstraction

Developer
    ↓
Code change
    ↓
Push to shared repository
    ↓
CI trigger
    ↓
Workflow starts
    ↓
Runner executes the job
    ↓
Steps execute
    ↓
Install dependencies
    ↓
Run tests
    ↓
Build
    ↓
Success or failure


## GitHub Actions

GitHub Actions is a CI/CD automation platform provided by GitHub.

It executes workflows defined in YAML files inside:

.github/workflows/


## Workflow

A workflow is the complete automation definition.

It defines:

- When the automation should run
- What jobs should run
- Which runner should execute the jobs
- Which steps should be performed

Example abstraction:

Workflow
    ↓
Job
    ↓
Steps


## Trigger

A trigger is an event that starts a workflow.

Example:

Push to main
    ↓
Workflow starts

In our workflow:

on:
  push:
    branches:
      - main

This means a push to the main branch triggers the workflow.

The trigger does NOT perform the Git push. Git performs the push; the trigger only tells GitHub Actions when to start the workflow.


## Job

A job is a group of related steps that are executed together.

Example:

jobs:
  test:

The job named test contains the steps required to validate the project.


## Runner

A runner is the machine/environment where a GitHub Actions job executes.

Example:

runs-on: ubuntu-latest

This tells GitHub Actions to run the job on an Ubuntu-based hosted runner.

The runner provides the environment where commands such as:

python3
pip
pytest
git

can execute.


## Step

A step is an individual task inside a job.

Examples:

- Checkout the repository
- Install dependencies
- Run tests
- Build the project

Steps normally execute sequentially.


## Action

An Action is a reusable automation component.

Example:

uses: actions/checkout@v4

The checkout action retrieves the repository code onto the runner.

Actions are reusable; we do not have to implement the checkout process ourselves.


## run

run executes a shell command or script on the runner.

Examples:

run: pytest

run: echo "Build started"

run can also execute multiple commands:

run: |
  pwd
  ls -la


## uses vs run

uses:
    Uses a reusable GitHub Action.

run:
    Executes a command or script directly on the runner.

Example:

uses: actions/checkout@v4

run: pytest


## Checkout

The runner starts with the repository code being retrieved using the checkout action.

Basic flow:

GitHub repository
    ↓
Checkout
    ↓
Repository files available on runner


## Dependencies

The runner is a fresh environment, so project dependencies need to be installed before testing.

For our Python project:

requirements.txt
    ↓
python3 -m pip install -r requirements.txt
    ↓
pytest available
    ↓
Tests can run


## Test

Testing verifies whether the application behaves as expected.

Our project uses pytest.

Flow:

Install dependencies
    ↓
pytest
    ↓
Tests pass or fail


If pytest returns exit code 0:

Test succeeds.

If pytest returns a non-zero exit code:

Test fails.

When a required step fails, later steps normally do not execute.


## Build

A build is the process of producing or preparing the application for the next stage.

The exact build process depends on the technology.

Examples:

Python:
    package/application preparation

Flutter:
    APK/IPA/build output

Java:
    JAR/WAR

Docker:
    Container image

In our simple CI practice, the Build step is currently represented by:

echo "Build started"


## Complete CI Mental Model

Developer
    ↓
Code change
    ↓
git push
    ↓
GitHub repository
    ↓
Trigger
    ↓
Workflow
    ↓
Job
    ↓
Runner
    ↓
Step: Checkout
    ↓
Step: Install dependencies
    ↓
Step: Test
    ↓
Step: Build
    ↓
Result


## Our Current CI Pipeline

Push to main
    ↓
Checkout code
    ↓
Check runner environment
    ↓
Install dependencies
    ↓
Run pytest
    ↓
Build


## Key Distinction

Git:
    Manages and versions the source code.

GitHub:
    Hosts the remote Git repository.

GitHub Actions:
    Executes automated workflows.

CI:
    The practice of automatically validating integrated code changes.

Workflow:
    Defines the automation.

Job:
    Groups related tasks.

Runner:
    Machine/environment executing the job.

Step:
    Individual task.

Action:
    Reusable automation component.

run:
    Executes a shell command or script.

Trigger:
    Event that starts the workflow.


## Core Principle

CI is not simply "GitHub Actions."

CI is the practice of automatically validating code changes.

GitHub Actions is the tool we are using to implement that CI process.