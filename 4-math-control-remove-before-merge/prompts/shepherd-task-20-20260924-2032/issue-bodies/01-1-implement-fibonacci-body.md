## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `4-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`

The resolved repository-validation decision is that the canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner; do not replace or bypass either contract.

The resolved behavior decision is that direct CLI execution writes exactly one result line to stdout in the form `Fibonacci(N) = value`, while functions return a numeric value without incidental output. Inputs are non-negative integers. The production and test files must be the repository-root files `math-tool.ps1` and `math-tool.Tests.ps1`.

No separate spike implementation pattern applies to this task. The campaign research established the validation, output, file-location, and serial-order constraints above; implement production code from those findings without reading, copying, or adapting spike source code.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for this work. This is implementation subsection 1 of 2.

The two campaign tasks are assigned, completed, and merged serially in plan order. Do not begin work until this issue is assigned. Task 2 must not begin until this issue's pull request is merged into `experiment/shepherd-control`. Leave unrelated campaign work for its later issue.

## Implement

Create `math-tool.ps1` with:

- A script parameter named `N` that accepts non-negative integer input.
- A pure `Get-Fibonacci` function that computes and returns the Fibonacci value as a number.
- Direct-execution behavior that invokes the function for `N` and writes exactly one stdout line: `Fibonacci(N) = value`.
- No incidental function output, diagnostic text, or extra CLI lines.

Create `math-tool.Tests.ps1` at the repository root with Pester tests that:

- Dot-source `math-tool.ps1` to test `Get-Fibonacci` directly.
- Exercise `N=0`, `N=1`, and at least one small representative value through the function.
- Launch isolated child `pwsh` processes to test direct CLI execution rather than treating dot-sourcing as a CLI test.
- Exercise `N=0`, `N=1`, and at least one small representative value through the CLI.
- Assert the exact single-line CLI contract, including capitalization, parentheses, spaces, equals sign, and computed value.
- Assert successful child-process exit for valid inputs.

Keep the script safely dot-sourceable: importing it for unit tests must not emit the direct-execution result line. Use production code and production dependencies in tests.

## Completion gates

- `math-tool.ps1` and `math-tool.Tests.ps1` are introduced together at the repository root.
- Function tests prove the numeric return values for 0, 1, and a representative input and fail if the function emits incidental pipeline output.
- Isolated child-process tests prove exact stdout and successful exit for the same boundary and representative inputs.
- A negative contract assertion or equivalent exact-output check ensures an extra line or formatting change would fail the suite.
- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero using the repository-owned runner and Pester 5.7.1.
- The pinned pull-request workflow passes.

## Out of scope

- Do not implement factorial or operation dispatch; those belong to task 2.
- Do not rename or relocate `math-tool.ps1`, `math-tool.Tests.ps1`, the test runner, or the workflow.
- Do not change the pinned Pester version or replace the repository-owned acceptance command.
- Do not add unrelated features, dependencies, documentation, or repository cleanup.
