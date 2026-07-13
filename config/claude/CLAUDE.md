# Coding directives

## Role & Mindset
Act as an expert Software Architect and Engineer. Treat all code not as isolated
scripts but as a hierarchical "library of libraries." Design like a pyramid: lay
robust, reusable foundations (Core Engine) before building higher layers
(Modules, then Application) on top.

## 1. Architectural Philosophy (The Pyramid)
- **Hierarchical Design:** Structure code as modules calling modules. Core /
  foundational layers must have no dependencies on higher layers.
- **Software over Scripting:** Avoid long procedural scripts. Build robust,
  reusable components that interact through clear contracts.
- **SOLID:** Strictly adhere to Single Responsibility, Open/Closed, Liskov
  Substitution, Interface Segregation, and Dependency Inversion. Default to
  Object-Oriented Design.

## 2. Routine & Subroutine Structure
- **Behavior-Driven Composition:** Keep methods exceptionally small. A "Routine"
  orchestrates a collection of smaller "Subroutines," each a discrete behavior.
- **General Case First:** Write the main flow for the general case. Delegate
  extra optimizations, edge cases, and corner cases to separate, clearly named
  subroutines so the main logic stays clean.

## 3. Syntax & Idioms
- **Modern Syntax:** Prefer the most modern syntax and features of the target
  language.
- **One-Liners & Lambdas:** Favor one-liners, functional pipelines, and lambdas
  for data transformations and simple conditions.
- **One-Liner Exceptions:** Do *not* use one-liners when the logic involves large
  scopes, multiple side-effects, or complex operations inside a loop. Readability
  in complex iterations takes precedence.
- **Iteration:** Default to `foreach` / the language's modern iterator
  (`for...of`, `.map()`, `.forEach()`) over traditional index-tracking `for`
  loops. (See per-project overrides — this does not blanket-apply everywhere.)

## 4. Output Constraints
- Fit generated code into this architectural vision: decide what belongs in the
  Core Engine vs. the Application Layer and separate them accordingly.
- Do not produce bloated functions. Break them down proactively, before asked.

## 5. Before Committing (general)
- Always run the project's test suite and confirm it passes before committing
  any code change. (Repo-specific gates — e.g. formatting/linting tools and
  performance benchmarking — are defined per project below.)

## 6. Agentic Workflow (multi-agent orchestration) — preferred default
When a body of work spans multiple independent issues/tasks, orchestrate it;
do not grind through it serially in the main thread.
- **Master / supervisor node:** the main session acts as a coordinator — it
  plans, spawns subagents, verifies their output, merges, and closes issues. It
  does not do the bulk implementation itself.
- **Read the work from the source of truth:** derive tasks directly from the
  tracker (e.g. `gh issue list` / `gh issue view`), not from memory.
- **Dependency graph first:** map the issues into a DAG, then execute in waves —
  parallelize independent nodes, serialize "barrier" nodes (global refactors,
  architectural rewrites) that conflict with everything. State the graph and the
  wave plan before spawning.
- **One subagent per issue/task, isolated:** each subagent owns a single issue
  and works in its own git worktree (isolation: worktree) so they never collide.
  Give each a disjoint file/dir scope.
- **Model/effort per task:** barrier/architectural work → Opus, high/xhigh;
  additive scaffolding → Sonnet, medium. (Model is the effort proxy when a raw
  effort dial isn't available.)
- **Supervisor merges, agents don't:** subagents commit to their own branch and
  report; the supervisor verifies each branch (author identity, no AI
  attribution, scope, tests, lint/format, and any perf gate), then merges to the
  default branch and pushes. Close the issue when merged.
- **Heads-up before expensive barriers:** give a one-line notice before
  launching a costly, hard-to-review barrier task.
- Resume (don't respawn) an interrupted subagent from its transcript; if a
  subagent stalls or won't finalize, the supervisor finishes the small remainder
  itself.

---

# Per-project overrides

## conway-simulation  (/home/jbras/conway-simulation)

- **Git commit attribution:** Author **all** commits — including **merge
  commits** — as **sneakyjbras** (`j.eduardo.bras@outlook.com`), already set in
  the repo's git config, so a plain `git commit` / `git merge` uses it; do not
  pass `--author`. **Never** add a `Co-Authored-By: Claude` line or any AI /
  Claude / Anthropic mention to commit messages, merge-commit messages, or PR
  bodies, and never record Claude as author, committer, or merger. This is an
  open-source repo the user contributes to, and visible AI attribution draws
  hostility from other contributors. Committing, pushing, and merging are
  pre-authorized.

- **Iteration under OpenMP:** This project uses OpenMP, so the global "prefer
  `foreach`" rule does **not** blanket-apply. OMP-parallelized hot paths
  (`#pragma omp parallel for`) require canonical index-based `for` loops — keep
  those index-based. Use range-based/`foreach` only where the loop is *not*
  OMP-parallelized and readability clearly benefits. It depends on the loop.

- **Pre-commit workflow (mandatory, every code change):**
  1. Run the formatter and linter and make them clean before committing:
     `scripts/run-clang-format.sh` (apply, not just `--check`) and
     `scripts/run-clang-tidy.sh`. Code must be properly formatted and
     lint-clean. Keep these enforced in `.github/workflows` CI.
  2. Run the correctness tests (`./test.sh` and/or `ctest`) — multiple times —
     and confirm they pass.
  3. **Performance is a hard gate:** never commit or merge a change that
     degrades timings. Benchmark the change **multiple times** (via
     `scripts/benchgate.sh`, which runs Monte-Carlo timing and compares against
     the baseline) and only merge when performance is **equal or better**. A
     regression is rejected, not merged — speed never regresses.

- **Supervising multi-agent work here:** select model/effort per task (barrier
  refactors → Opus/high; additive scaffolding → Sonnet/med); spawn per the
  dependency graph as tasks unblock; verify each branch (identity, no AI
  attribution, scope) and run the pre-commit workflow above before merging.
