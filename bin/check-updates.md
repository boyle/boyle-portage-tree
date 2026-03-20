# check-updates - Gentoo Overlay Update Checker

## Overview

Checks for upstream updates of packages in a Gentoo overlay by comparing GitHub release/tag versions against installed packages.

## Dependencies

- xmllint
- grep, sort, tail, ls, sed
- curl
- jq

**Note:** `equery` is no longer required. Installed version detection now uses `/var/db/pkg` directly.

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `PORTDIR_OVERLAY` | No | Git root | Path to overlay directory |
| `GITHUB_TOKEN` | No | None | GitHub API token for higher rate limits (60 → 5000 req/hr) |

## Command Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-p, --parallel N` | Run N concurrent API requests (default: 1) |
| `--no-cache` | Disable caching of API responses |
| `--clear-cache` | Clear cache and exit |

## Functional Requirements

### FR1: Package Discovery

- MUST scan overlay recursively for `*.ebuild` files
- MUST return unique category/package pairs
- MUST skip `acct-user/*` and `acct-group/*` directories
- `-9999` live ebuilds are filtered out when checking for available versions

### FR2: GitHub Repository Lookup

- MUST read `metadata.xml` from each package directory
- MUST extract `remote-id[@type='github']` value using XPath via xmllint

### FR3: Version Fetching

- MUST query GitHub Releases API as primary source
- MUST fall back to GitHub Tags API if no releases found
- MUST strip `v` prefix from version strings
- MUST return empty string on API failure
- MUST respect GitHub API rate limits

### FR4: Version Comparison

- MUST fetch upstream version from GitHub
- MUST detect installed version via `/var/db/pkg`
- MUST determine if installed version matches upstream
- MUST find highest versioned ebuild in overlay (for future use)

### FR5: Output Format

Output one line per package in format: `name: version (status)`

| Status Condition | Output |
|------------------|--------|
| Upstream matches installed | `name: 1.2.3 (up to date)` |
| Installed but outdated | `name: 1.2.4 (1.2.3, installed)` |
| Not installed | `name: 1.2.4 (not installed)` |
| No GitHub remote-id | `name: (non-github source)` |
| API error | `name: (github api error)` |

### FR6: Caching

- API responses cached for 1 hour in `~/.cache/check-updates`
- Cache can be disabled with `--no-cache`
- Cache can be cleared with `--clear-cache`

### FR7: Rate Limiting

- Unauthenticated requests limited to 60/hour
- Authenticated requests (via `GITHUB_TOKEN`) limited to 5000/hour
- Rate limit status shown in stderr when exceeded

## Error Handling

| Error | Behavior |
|-------|----------|
| Missing dependency | Exit 1 with "error: <tool> missing" |
| PORTDIR_OVERLAY not set and not in git repo | Exit 1 with error message |
| Unknown command-line option | Exit 1 with "Unknown option" |
| GitHub API rate limit exceeded | Continue, show rate limit warning to stderr |

## Exit Codes

- `0`: All checks completed
- `1`: Error (missing tool, invalid usage, or repo not found)

## GitHub API Rate Limits

Without authentication, GitHub limits API requests to 60 per hour per IP. This can be exhausted quickly when checking many packages.

### Setting Up a GitHub Token

1. Create a GitHub Personal Access Token at https://github.com/settings/tokens
2. No specific scopes are required (public repo info is read-only)
3. Export the token:

```bash
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

Or pass it inline:

```bash
GITHUB_TOKEN="ghp_xxx" ./bin/check-updates
```

With a token, the rate limit increases to 5,000 requests per hour.

## Performance

For large overlays, use parallel mode:

```bash
./bin/check-updates -p 5
```

This runs 5 concurrent API requests. The default is 1 (sequential).

## Example Output

```
clgpustress: 0.0.9.4 (up to date)
gputest: (non-github source)
obsidian: 1.12.4 (1.6.7, installed)
opencode-bin: 1.2.27 (up to date)
verilator: 5.046 (5.044, installed)
viu: 1.6.1 (up to date)
yosys: 0.63 (up to date)
```

### Error Output Example

Rate limit warnings are sent to stderr:

```
$ ./bin/check-updates
rate-limited (set GITHUB_TOKEN for higher limits)
clgpustress: 0.0.9.4 (up to date)
verilator: (github api error)
```

## Usage Patterns

### Cronjob Notifications

Run in a cron job to notify when packages need updating. Only stderr is sent to the user:

```bash
# crontab example: run daily at 8am
0 8 * * * /path/to/check-updates >/dev/null
```

- **stdout** (version info) is discarded
- **stderr** (errors like API failures) is delivered to the user
- A non-empty output from stderr indicates problems requiring attention

### With Parallel Mode for Faster Checks

```bash
# Check all packages with 4 concurrent requests
./bin/check-updates -p 4

# Disable caching for fresh results
./bin/check-updates --no-cache -p 4
```

### AI-Assisted Ebuild Creation

Output can be piped to an AI assistant to create or update ebuilds. The AI should:
- Only modify files under explicit user supervision
- Create new ebuilds when upstream version differs from available versions
- Follow Gentoo ebuild conventions (EAPI=8, proper quoting, etc.)
- Run pkgcheck to verify QA before presenting changes to the user

Example workflow:
```bash
# User reviews updates
./bin/check-updates

# User decides to update a specific package
# User asks AI to create new ebuild, providing:
#   - Current ebuild location and contents
#   - Upstream version to package
#   - GitHub release/tarball URL

# AI creates ebuild under user supervision
# User reviews and approves changes
```

## Testing

### Verification Commands

```bash
# Run check-updates
./bin/check-updates

# Run with parallel mode
./bin/check-updates -p 4

# Clear cache
./bin/check-updates --clear-cache

# Verify dependency check (remove xmllint temporarily)
```

### Expected Results

- All packages with GitHub remote-ids show upstream versions
- Non-GitHub packages show `(non-github source)`
- Installed packages show installed version in parentheses
- Rate limit warnings appear in stderr when exceeded
