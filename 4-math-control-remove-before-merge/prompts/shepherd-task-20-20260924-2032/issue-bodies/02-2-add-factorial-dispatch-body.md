## Campaign context and required reading

On the `experiment/shepherd-control` branch, the directory `4-math-control-remove-before-merge` contains the plan (`math-tool-ignorance-reduction-plan.md`) and supporting resources (diagrams, decision records). Spike subdirectories are research artifacts — read the plan's Resolution sections for findings, not the spike source code.

Read the entire plan before working. Then carefully re-read these exact sections:

- `## Ignorance reduction`
- `### Repository-owned validation`
- `### Output and ordering contracts`
- `## Implementation`
- `### 1. Implement Fibonacci with unit and isolated CLI coverage`
- `### 2. Add factorial and operation dispatch`

The resolved repository-validation decision is that the canonical acceptance command is `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1`. The existing workflow `.github/workflows/shepherd-task-math-tool.yml` installs exactly Pester 5.7.1 and invokes that repository-owned runner; do not replace or bypass either contract.

The resolved behavior decision is that direct CLI execution writes exactly one result line to stdout: `Fibonacci(N) = value` or `Factorial(N) = value`. Functions return numeric values without incidental output, and inputs are non-negative integers. The implementation and test files remain the repository-root `math-tool.ps1` and `math-tool.Tests.ps1`. Fibonacci behavior delivered by task 1 is a compatibility contract and must be preserved.

No separate spike implementation pattern applies to this task. The campaign research established the validation, output, compatibility, file-location, and serial-order constraints above; implement production code from those findings without reading, copying, or adapting spike source code.

## Branch and execution order

Use `experiment/shepherd-control` from remote `origin` as the base branch for this work. This is implementation subsection 2 of 2.

The two campaign tasks are assigned, completed, and merged serially in plan order. Do not begin work until this issue is assigned, and only after task 1 has been merged into `experiment/shepherd-control`. Build on the merged task-1 implementation and tests rather than recreating or bypassing them.

## Implement

Extend the existing repository-root `math-tool.ps1` with:

- A pure `Get-Factorial` function that accepts non-negative integer `N` and returns the factorial as a number.
- An `Operation` parameter that dispatches between `fibonacci` and `factorial` while retaining the existing `N` parameter.
- Direct factorial execution that writes exactly one stdout line in the form `Factorial(N) = value`.
- Preserved Fibonacci execution that continues to write exactly one stdout line in the form `Fibonacci(N) = value`.
- No incidental function output, diagnostic text, or extra CLI lines.

Extend `math-tool.Tests.ps1` with objective Pester coverage that:

- Dot-sources `math-tool.ps1` and tests `Get-Factorial` directly for `N=0`, `N=1`, and at least one small representative value.
- Uses isolated child `pwsh` processes to exercise factorial operation dispatch and exact direct-CLI output for the same edge and representative values.
- Re-runs the existing Fibonacci unit and isolated CLI cases through the finalized interface so operation dispatch cannot regress task-1 behavior.
- Verifies successful child-process exits for both supported operations and exact single-line output, including capitalization, parentheses, spaces, equals sign, and computed value.

Keep both functions safely dot-sourceable: importing the script for unit tests must not execute operation dispatch or emit a result line. Preserve the existing small, repository-owned test infrastructure.

## Completion gates

- `Get-Factorial` returns numeric values 1 for `N=0`, 1 for `N=1`, and the correct result for a representative positive input without incidental pipeline output.
- Factorial CLI tests prove operation selection, exact stdout, and successful exit in isolated child processes.
- The combined suite retains and passes Fibonacci function and CLI regression coverage through the finalized `Operation` interface.
- Exact-output assertions fail on extra output lines or formatting drift for both operations.
- `pwsh -NoLogo -NoProfile -File ./eng/test-math-tool.ps1` exits zero for the combined regression suite using Pester 5.7.1.
- The pinned pull-request workflow passes.

## Out of scope

- Do not add operations other than `fibonacci` and `factorial`.
- Do not redesign or relocate `math-tool.ps1`, `math-tool.Tests.ps1`, the test runner, or the workflow.
- Do not weaken or remove task-1 Fibonacci behavior or tests.
- Do not change the pinned Pester version or replace the repository-owned acceptance command.
- Do not add unrelated features, dependencies, documentation, or repository cleanup.
