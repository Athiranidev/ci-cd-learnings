# GitHub Actions workflow_dispatch

## What is workflow_dispatch?

`workflow_dispatch` is a GitHub Actions trigger that allows a workflow to be started manually from the GitHub Actions UI.

Normal automatic triggers can include:

    push
    pull_request

A manual trigger is:

    workflow_dispatch

Example:

    on:
      push:
        branches:
          - main

      pull_request:
        branches:
          - main

      workflow_dispatch:

This means the workflow can start in three ways:

    Push to main
        ↓
    Automatic workflow

    Pull request to main
        ↓
    Automatic workflow

    Run workflow from GitHub Actions
        ↓
    Manual workflow

## Why use workflow_dispatch?

`workflow_dispatch` is useful when a workflow should be started deliberately by a person.

Common examples include:

- Manually running a CI workflow
- Manually starting a deployment
- Maintenance tasks
- Administrative tasks
- Running an operational workflow on demand
- Testing a workflow without requiring a new push

## Automatic trigger vs manual trigger

Automatic trigger:

    git push
        ↓
    GitHub event
        ↓
    Workflow starts automatically

Manual trigger:

    GitHub Actions
        ↓
    Run workflow
        ↓
    User starts the workflow
        ↓
    Workflow executes

`workflow_dispatch` does not automatically run a workflow. It makes the workflow available for manual execution.

## Basic syntax

    on:
      workflow_dispatch:

It can be combined with other triggers:

    on:
      push:
        branches:
          - main

      pull_request:
        branches:
          - main

      workflow_dispatch:

The existing automatic triggers continue to work.

## Important distinction

`workflow_dispatch` changes how the workflow is triggered.

It does not automatically select a particular step or detect a failed step and run only that step.

For example, if a workflow contains:

    Checkout
        ↓
    Install dependencies
        ↓
    Test
        ↓
    Docker build
        ↓
    Docker push

Manually starting the workflow runs the workflow according to its configured jobs and steps.

It does not mean:

    "Find the step that previously failed and run only that step."

Selective execution requires explicit workflow design using jobs, inputs, conditions, or other workflow features.

## workflow_dispatch and jobs

A workflow can contain multiple jobs:

    test
      ↓
    build
      ↓
    deploy

`workflow_dispatch` can manually start the workflow, while job dependencies such as `needs` still control the execution order.

Example:

    build:
      needs: test

The manual trigger does not remove or change that dependency.

## Practical implementation

The CI workflow was updated with:

    workflow_dispatch:

The workflow already had automatic triggers for:

    push
    pull_request

After adding `workflow_dispatch`, the workflow could also be started manually.

The workflow was tested through GitHub Actions and produced a run showing:

    workflow-dispatch

This verified that the manual trigger was working.

## Practical CI structure

The project currently has a CI workflow containing:

    test
      ├── Python 3.11
      ├── Python 3.12
      └── Python 3.13
              ↓
            build
              ↓
          Docker push

`workflow_dispatch` can manually start this workflow without requiring a new code push.

## Core mental model

    push
       ↓
    automatic trigger

    pull_request
       ↓
    automatic trigger

    workflow_dispatch
       ↓
    human manually starts workflow

The key idea:

    workflow_dispatch
        ↓
    Manual workflow trigger
        ↓
    Workflow executes according to its existing jobs and steps