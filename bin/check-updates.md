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
- MUST find highest versioned ebuild in overlay
- MUST determine icon based on comparison of all three versions
- MUST include `(ebuild ...)` and `(installed ...)` only when they differ from upstream

### FR5: Output Format

Output one line per package in format: `<icon> <name>: <upstream version> [(ebuild <version>)][(installed <version>)]`

Optional version info is only shown when it differs from upstream.

#### Icon Legend

| Icon | Meaning | Action Required |
|------|---------|-----------------|
| (blank) | Up to date | None |
| `↑` | Update available | Run `emerge pkg` to update installed package |
| `+` | Ebuild needs update | Create or update ebuild before installing |
| `o` | Not installed | Run `emerge pkg` to install |
| `?` | Non-GitHub source | Manual check needed |
| `!` | API error | Investigate |
| `~` | Anomaly detected | Warning: installed version is newer than ebuild |

#### Icon Logic

Icons are determined by comparing upstream, ebuild, and installed versions. Priority determines which icon is shown when multiple conditions apply.

| Priority | Icon | Condition | Rationale |
|----------|------|-----------|-----------|
| 1 | `!` | GitHub API error | Cannot fetch upstream version |
| 2 | `~` | installed > ebuild | Warning: ebuild is behind installed version |
| 3 | `+` | upstream > ebuild | Ebuild needs updating before install |
| 4 | `↑` | ebuild = upstream > installed | Matching ebuild exists; just update installed |
| 5 | `o` | installed = none AND upstream = ebuild | Ready to install |
| 6 | (blank) | upstream = installed = ebuild | Everything in sync |

#### Example Output

```
  clgpustress:  0.0.9.4
↑ verilator:    5.046 (installed 5.044)
o opencode-bin: 1.2.27
+ obsidian:     1.12.4 (ebuild 1.6.7)
+ svls:         0.2.14 (ebuild 0.2.12, installed 0.2.12)
? gputest:      non-github source
! ollama:       api error
~ viu:          1.6.1 (WARNING: ebuild 1.5.0 is behind installed)
```

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
  clgpustress:  0.0.9.4
  ollama:       0.18.2
  opencode-bin: 1.2.27
  svls:         0.2.14 (ebuild 0.2.12)
  viu:          1.6.1
  yosys:        0.63
↑ verilator:    5.046 (installed 5.044)
+ obsidian:     1.12.4 (ebuild 1.6.7)
? gputest:      non-github source
! unknown-pkg:  api error
~ broken-pkg:   2.0.0 (WARNING: ebuild 1.0.0 is behind installed)
```

Note: Output is sorted alphabetically. Error conditions (`?`, `!`, `~`) appear at the end.

### Stderr Output

Rate limit warnings and other errors are sent to stderr:

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

- Packages up-to-date show no icon
- Packages needing update show `↑` with installed version
- Packages with ebuild behind upstream show `+`
- Packages not installed show `o` or `+` depending on ebuild status
- Non-GitHub packages show `?` with "non-github source"
- API errors show `!` with "api error"
- Anomalies (installed > ebuild) show `~` with warning
- Output is sorted alphabetically
- Rate limit warnings appear in stderr when exceeded
