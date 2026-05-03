Run a BDD feature file's pytest stub with the correct environment and region.

## Arguments

`$ARGUMENTS` is a string in the form:

```
<feature_name> [--env|-e <environment>] [--region|-r <region>] [--serial|-s]
```

- `<feature_name>` — required, the feature file base name without path or `.feature` extension (e.g. `site_based_observations`, `time_series`, `historical_postal`)
- `--env` / `-e` — optional, one of `qa`, `prod`, `fastly`, `legacy` (default: `qa`)
- `--region` / `-r` — optional, one of `auto`, `use1`, `usw2`, `euw1`, `apse1` (default: `auto`)
- `--serial` / `-s` — optional flag, runs tests serially; omit to run in parallel (default: parallel)

## Steps

0. **No arguments — show help and stop**
   If `$ARGUMENTS` is empty or blank, print the following exactly and do nothing else:

   ```
   Usage: /bdd <feature_name> [options]

   Run a BDD feature file's pytest stub against a target environment.

   Arguments:
     feature_name          Feature file base name (no path, no .feature extension)
                           e.g. site_based_observations, time_series, historical_postal

   Options:
     -e, --env ENV         Target environment  [default: qa]
                           Choices: qa, prod, fastly, legacy
     -r, --region REGION   Target region  [default: auto]
                           Choices: auto, use1, usw2, euw1, apse1
     -s, --serial          Run tests serially instead of in parallel

   Examples:
     /bdd site_based_observations
     /bdd time_series --env prod
     /bdd historical_postal -e prod -r use1
     /bdd historical_postal -e prod -r use1 --serial
     /bdd cod/v3/atomic/postal --env qa --region use1
   ```

1. **Parse `$ARGUMENTS`**
   - The first token (before any flag) is the feature name. Strip a trailing `.feature` if the user included it.
   - Scan remaining tokens for `--env`/`-e` and `--region`/`-r` flags and their values.
   - Check for the presence of `--serial` or `-s` (boolean flag, no value).
   - Apply defaults: environment = `qa`, region = `auto`, serial = `false`.

2. **Locate the feature file** with a single Bash command:
   ```bash
   find features/ -name "<feature_name>.feature" 2>/dev/null
   ```
   - If zero results: report "No feature file named `<feature_name>.feature` found under features/." and stop.
   - If multiple results: list them and ask the user which one to use.

3. **Derive the test stub path** from the feature file path:
   - Replace the `features/` prefix with `tests/bdd/`
   - Rename `<name>.feature` → `test_<name>.py`
   - Example: `features/cod/v1/site_based_observations.feature` → `tests/bdd/cod/v1/test_site_based_observations.py`

4. **Verify the stub exists**:
   ```bash
   test -f <derived_path> && echo "found" || echo "missing"
   ```
   - If missing, fall back to a recursive search:
     ```bash
     find tests/bdd -name "test_<feature_name>.py" 2>/dev/null
     ```
   - If still not found: report "No test stub found for `<feature_name>`." and stop.
   - If the fallback finds multiple matches, list them and ask the user which to use.

5. **Run pytest** with the environment variables set inline:
   - Default (parallel):
     ```bash
     ENVIRONMENT=<environment> REGION=<region> uv run pytest <test_path> -n auto -v
     ```
   - With `--serial` / `-s`:
     ```bash
     ENVIRONMENT=<environment> REGION=<region> uv run pytest <test_path> -v
     ```
   - Do not use `invoke test` — call pytest directly so there is no `clean` pre-task and no marker filtering.
   - Run in the foreground so output streams to the terminal.

6. **Report results**: after pytest exits, produce a structured summary.

   **Header line:**
   > **Results: `<N> passed, <N> failed, <N> skipped`** — `<env>/<region>`, `<elapsed>`

   If there were no failures, append "All tests passed." and stop here.

   **Failure detail blocks** — output one block per failed test:

   ```
   FAIL  <human-readable scenario name>
         Step:     <failing step quoted verbatim, e.g. "Then the response status code should be 400">
         Expected: <expected value or status>
         Got:      <actual value or status>
   ```

   Extract the **Step** from the BDD traceback (`Step: Then ...` line). If not present, use the last line before the `AssertionError`.

   Extract **Expected** and **Got** from the `AssertionError` message (e.g. `AssertionError: Response status code was 404 expected 400` → Expected: 400, Got: 404). If it does not split cleanly, use a single `Reason:` line quoting the full message.

   **Diagnosis** — if all failures share a common root cause, add one plain-English sentence after the last failure block (e.g. "All failures are postal key tests returning `NDF-0001` — consistent with an expired data feed in the QA environment.").
