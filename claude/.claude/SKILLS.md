# Skills Catalog

A reference for all Claude Code skills available in this configuration. Skills are invoked with `/skill-name` in any Claude Code session.

Skills marked **★** are among the most frequently used (based on session history analysis).

---

## How to maintain this catalog

Run `/skill-gaps` periodically to analyze session history and surface new skill candidates. When you add a new skill, add a one-line entry here under the appropriate category.

---

## Git Workflow

| Skill | What it does |
|---|---|
| `/ship` ★ | Branch → commit → push → PR. Use `-m` to commit directly to main, `-p` for a patch release to main. |
| `/main` ★ | Checkout main, pull latest, delete merged branches. |
| `/sync` | Rebase current feature branch onto latest main. |
| `/commit` | Create a well-formatted conventional commit for staged changes. |
| `/fix` | Run code review and apply all findings (Must Fix + Should Fix + Consider), looping until clean. Shorthand for `/code-review -fc`. |

---

## Code Quality

| Skill | What it does |
|---|---|
| `/code-review` ★ | Structured review of changed files. Use `-f` to fix once, `-fc` to fix and loop until clean. |
| `/refactor` | Restructure code for clarity and maintainability without changing behavior. |
| `/migrate` | Replace deprecated APIs and outdated idioms with current equivalents. |
| `/simplify` | Review changed code for reuse, quality, and efficiency, then fix issues found. |
| `/debug` | Diagnose errors, exceptions, and unexpected behavior. |
| `/security-review` | Review code for security vulnerabilities. |

---

## SUN QA Testing

| Skill | What it does |
|---|---|
| `/run-tests` | Clear allure results, run BDD tests against `<env>/<region>` (e.g. `qa/use1`), analyze failures. |
| `/bdd` | Run a BDD feature file's pytest stub with the correct environment and region. |
| `/allure-analyzer` | Parse `allure-results/` from a pytest run and produce a structured failure triage report. |
| `/suggest` | Identify untested API behavior in the current SUN acceptance test repo and generate Gherkin scenarios. |
| `/sun-qa-tdd` | TDD guidance for SUN QA — use before writing implementation code. |
| `/marker-audit` ★ | Diff markers used in feature files and test modules against `pytest.ini`; report missing/unused registrations. |
| `/pytest-audit` | Audit the pytest configuration and test structure for anti-patterns. |
| `/weather-coverage` | Check test coverage against weather API endpoints. |

---

## SUN Repo Management

| Skill | What it does |
|---|---|
| `/repo-upgrade` | Audit a SUN acceptance test repo with `audit-repo-migration`, then apply fixes with `upgrade-repo`. |
| `/import-upgrade-task` | Copy the canonical `upgrade` task from `sun-location-acceptance-tests/tasks.py` into the current repo. |
| `/bump-tools` | Upgrade `sun-devops-python-tools`, `sun-gis-python-tools`, and `sun-qa-python-tools` to latest. |
| `/fix-uv-jenkins-auth` ★ | Fix the broken `UV_EXTRA_INDEX_URL` credential pattern in Jenkinsfiles. |
| `/coverage-pages` ★ | Wire up `coverage-badge` + GitHub Pages so the README badge links to an `htmlcov/` report. |
| `/update-secrets` | Update `ARTIFACTORY_USER`, `ARTIFACTORY_TOKEN`, and `GH_TOKEN` GitHub repo secrets from local env vars. |

---

## Infrastructure & Jenkins

| Skill | What it does |
|---|---|
| `/jenkinsfiles` | Review all Jenkinsfiles in the repo for correctness, credential handling, and best practices. |
| `/jenkins-failures` ★ | List all Jenkins job failures across configured regions. |
| `/jenkins-analyze` | Deep analysis of a specific Jenkins build failure. |
| `/fix-uv-jenkins-auth` | Fix uv Artifactory auth — see SUN Repo Management above. |
| `/hostnames` ★ | Extract DNS hostnames for a named service across clusters and validate against `ingress-mapping.yaml`. |
| `/ingress-validator` | Validate ingress mapping configuration. |
| `/helm-review` | Review Helm charts for correctness and best practices. |
| `/setup-postsync-jenkins` | Configure the post-sync Jenkins webhook for a repo. |

---

## Weather Domain

| Skill | What it does |
|---|---|
| `/weather` | Get current conditions for a location. |
| `/weather-history` | Retrieve historical weather data. |
| `/weather-compare` | Compare weather across locations or time periods. |
| `/storm-check` | Check for active storms near a location. |
| `/health-check` | Check service health status. |
| `/health-brief` | Brief health summary for a region or service. |
| `/nearby-stations` | Find weather stations near a location. |
| `/lsd-matrix` | Location Service Database query matrix. |
| `/location-info` | Look up location metadata. |
| `/location-fixture` | Generate a location fixture for testing. |

---

## WireMock

| Skill | What it does |
|---|---|
| `/wiremock-gen-mapping` | Generate a WireMock mapping from a sample request/response. |
| `/wiremock-gen-scenario` | Generate a stateful WireMock scenario (multi-step stub). |
| `/wiremock-gen-fault` | Generate a WireMock fault or error response mapping. |
| `/wiremock-debug` | Diagnose why a WireMock request is not matching the expected stub. |
| `/wiremock-record` | Record live traffic into WireMock mappings. |
| `/wiremock-verify` | Verify WireMock mapping files for correctness and conflicts. |

---

## Documentation

| Skill | What it does |
|---|---|
| `/docs` | Generate or update documentation for the current project. |
| `/doc-review` | Review documentation against the Write the Docs principles. |
| `/release-notes` | Generate a changelog / release notes from git history. |
| `/user-story` | Break a raw story description into INVEST-compliant user stories with Gherkin criteria. |
| `/invest` | Review an existing user story for INVEST compliance. |

---

## Agile & Planning

| Skill | What it does |
|---|---|
| `/architect` | Design an implementation plan before coding. |
| `/jira-templates` | Generate Jira ticket templates. |
| `/work` | Work journal — log, list, and track in-progress work. |

---

## Language-Specific Generation

| Skill | What it does |
|---|---|
| `/go-feature` | Scaffold a new Go feature with tests. |
| `/go-docs` | Generate Go documentation. |
| `/go-bench` | Write Go benchmarks for a function or package. |
| `/py-feature` | Scaffold a new Python feature with tests. |
| `/py-docs` | Generate Python documentation. |
| `/py-bench` | Write Python benchmarks. |
| `/nvim-feature` | Scaffold a Neovim plugin feature with tests. |
| `/nvim-docs` | Generate Neovim plugin documentation. |
| `/nvim-bench` | Write Neovim plugin benchmarks. |
| `/gherkin-feature` | Scaffold a Gherkin feature file with scenarios. |
| `/gherkin-docs` | Generate documentation from Gherkin feature files. |

---

## Claude Config & Meta

| Skill | What it does |
|---|---|
| `/skill-gaps` | Analyze session history to find repeating tasks with no skill coverage. Run periodically to find new skill candidates. |
| `/skill-audit` | Audit existing skill files for structural quality and consistency. |
| `/skill-author` | Author a new skill file with correct structure and language. |
| `/audit` | Audit the Claude workflow system (rules, skills, agents, hooks) and report what's suboptimal. |
| `/patterns` | Design patterns reference — all 22 GoF patterns with signals and trade-offs. |
| `/pwd` ★ | Report current working directory with project context (language, type, git status). |
| `/update-config` | Configure Claude Code via `settings.json` — hooks, permissions, env vars. |
| `/keybindings-help` | Customize keyboard shortcuts in `~/.claude/keybindings.json`. |
| `/fewer-permission-prompts` | Scan transcripts for common tool calls and add them to the allowlist. |

---

## Utilities

| Skill | What it does |
|---|---|
| `/sql` | Write, explain, or optimize SQL queries. |
| `/bench` | Run benchmarks for the current project. |
| `/test-runner` | Run the test suite and report only failures. Detects pytest, jest, vitest, and make automatically. |
| `/test-driven-development` | TDD reference — red/green/refactor cycle, tooling, and anti-patterns. |
| `/research` | Research a topic and return a structured summary. |
| `/mcp-test` | Test MCP server connectivity and tool availability. |
| `/loop` | Run a prompt or slash command on a recurring interval. |
| `/schedule` | Create or manage scheduled remote agents (cron routines). |
| `/init` | Initialize a new project with standard Claude configuration. |

---

## How skills were identified

The skills in this catalog were discovered by running `/skill-gaps` against session history (`~/.claude/history.jsonl`). The analysis looks at:

1. **Skill invocations** — which `/skill` commands appear most often (confirms what's working)
2. **Freeform patterns** — natural language phrases typed 5+ times that no skill covers

The 7 skills added on 2026-05-17 based on this analysis:

| Skill | Evidence |
|---|---|
| `/fix` | "address all findings" typed ~140 times after `/code-review` |
| `/repo-upgrade` | "run audit-repo-migration first, then upgrade-repo" typed 12 times verbatim |
| `/import-upgrade-task` | "import the upgrade task from ../sun-location-acceptance-tests/tasks.py" typed 8 times identically |
| `/bump-tools` | "update to the latest version of sun-qa-python-tools" appeared 6+ times explicitly |
| `/run-tests` | "run the tests against qa/use1" and similar appeared 58 times |
| `/jenkinsfiles` | "review my jenkinsfiles" appeared 8 times |
| `/skill-gaps` | The analysis itself is now a repeatable skill |

**Discoverability gap found:** `/commit` exists with 0 invocations while "commit and push changes" was typed 381 times. Consider using `/commit` for staging + committing before `/ship`.
