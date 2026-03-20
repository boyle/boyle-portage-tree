# check-updates - Gentoo Overlay Update Checker

## Overview

Checks for upstream updates of packages in a Gentoo overlay by comparing GitHub release/tag versions against installed packages.

## Dependencies

- xmllint
- grep, sort, tail, ls, sed
- curl
- jq
- equery (from gentoolkit)

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORTDIR_OVERLAY` | No | Git root | Path to overlay directory |

## Functional Requirements

### FR1: Package Discovery

- MUST scan overlay recursively for `*.ebuild` files
- MUST return unique category/package pairs
- MUST skip `acct-user/*` and `acct-group/*` directories

### FR2: GitHub Repository Lookup

- MUST read `metadata.xml` from each package directory
- MUST extract `remote-id[@type='github']` value using XPath via xmllint

### FR3: Version Fetching

- MUST query GitHub Releases API as primary source
- MUST fall back to GitHub Tags API if no releases found
- MUST strip `v` prefix from version strings
- MUST return empty string on API failure

### FR4: Version Comparison

- MUST fetch upstream version from GitHub
- MUST detect installed version via `equery list`
- MUST determine if installed version matches upstream

### FR5: Output Format

Output one line per package in format: `name: version (status)`

| Status Condition | Output |
|------------------|--------|
| Upstream matches installed | `name: 1.2.3 (up to date)` |
| Installed but outdated | `name: 1.2.4 (1.2.3, installed)` |
| Not installed | `name: 1.2.4 (not installed)` |
| No GitHub remote-id | `name: (non-github source)` |
| API error | `name: (github api error)` |

## Error Handling

| Error | Behavior |
|-------|----------|
| Missing dependency | Exit 1 with "error: <tool> missing" |
| PORTDIR_OVERLAY not set and not in git repo | Exit 1 with error message |
| Command-line arguments provided | Exit 1 with usage message |

## Exit Codes

- `0`: All checks completed
- `1`: Error (missing tool, invalid usage, or repo not found)

## Example Output

```
clgpustress: 0.0.9.4 (up to date)
gputest: (non-github source)
obsidian: 1.12.4 (1.6.7, installed)
opencode-bin: 1.2.27 (up to date)
viu: 1.6.1 (up to date)
svls: 0.2.14 (up to date)
verilator: 5.046 (5.044, installed)
yosys: 0.63 (up to date)
ollama: 0.18.2 (up to date)
```

## Testing

### Verification Commands

```bash
# Run check-updates
./bin/check-updates

# Verify dependency check (remove xmllint temporarily)
```

### Expected Results

- All packages with GitHub remote-ids show upstream versions
- Non-GitHub packages show `(non-github source)`
- Installed packages show installed version in parentheses
