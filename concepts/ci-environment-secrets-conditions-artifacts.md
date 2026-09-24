# CI Environment Variables, Secrets, Conditions and Artifacts

## 1. Environment Variables

An environment variable is a named value made available to a process or job.

Example:

    env:
      APP_ENV: testing

A step can access it:

    run: echo "Running in $APP_ENV environment"

Mental model:

    Job
      ↓
    Environment variable
      ↓
    Steps can use the value

Environment variables are useful for configuration values that are not sensitive.

---

## 2. GitHub Actions Secrets

Secrets are used for sensitive values such as:

- API keys
- Passwords
- Access tokens
- Credentials

Secrets should not be hardcoded in the workflow or source code.

A repository secret can be accessed with:

    ${{ secrets.DEMO_SECRET }}

Example:

    - name: Check secret
      run: |
        if [ -n "$DEMO_SECRET" ]; then
          echo "Secret is available"
        else
          echo "Secret is missing"
          exit 1
        fi
      env:
        DEMO_SECRET: ${{ secrets.DEMO_SECRET }}

The workflow receives the actual secret value, but the workflow should not intentionally print it.

Important distinction:

    Environment variable → normal configuration
    Secret             → sensitive configuration

---

## 3. Conditions

GitHub Actions supports conditions using `if:`.

A condition determines whether a step or job should run.

Example:

    - name: Conditional message
      if: success()
      run: echo "Tests succeeded"

`success()` is a built-in GitHub Actions function.

It means the condition is true when the required previous work succeeded.

Another built-in function is:

    if: failure()

which can be used when previous work has failed.

The general mental model is:

    condition
        ↓
      TRUE  → step runs
      FALSE → step is skipped

Conditions can also use values such as environment variables, branch/event information and other GitHub Actions context.

Important:

`if:` in GitHub Actions is different from:

    if [ -n "$DEMO_SECRET" ]; then

The second example is a Bash shell condition.

`if:` controls GitHub Actions execution.

Bash `if` controls commands inside the shell.

---

## 4. Artifacts

An artifact is a file or collection of files produced during a workflow run that is uploaded and preserved after the runner finishes.

Example:

    - name: Build
      run: |
        mkdir -p build
        echo "CI build successful" > build/build.txt

    - name: Upload build artifact
      uses: actions/upload-artifact@v4
      with:
        name: python-build
        path: build/

`build/build.txt` is created on the runner.

`actions/upload-artifact@v4` uploads it so it can be accessed after the job finishes.

Important distinction:

    cat build/build.txt
        ↓
    Shows the file in the workflow log

    upload-artifact
        ↓
    Preserves the file as a workflow artifact

---

## 5. Overall CI Mental Model

    Git push
       ↓
    Trigger
       ↓
    Workflow
       ↓
    Job
       ↓
    Runner
       ↓
    Steps
       ↓
    Dependencies
       ↓
    Tests
       ↓
    Conditions
       ↓
    Build
       ↓
    Artifact

Environment variables provide configuration.
Secrets provide sensitive configuration.
Conditions control whether work runs.
Artifacts preserve files produced by the workflow.