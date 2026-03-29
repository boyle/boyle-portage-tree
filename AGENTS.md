# AGENTS.md - portage

Gentoo overlay containing ebuilds for various tools.

## Current Packages

Run to list packages in the overlay:

```bash
find . -name "*.ebuild" ! -name "*-9999.ebuild" | sed 's|^\./||; s|/[^/]*$||' | sort -u
```

## Build/Lint/Test Commands

### Running pkgcheck (QA)

```bash
# Scan entire overlay
PORTDIR_OVERLAY=/home/boyle/proj/portage pkgcheck scan

# Scan specific package
PORTDIR_OVERLAY=/home/boyle/proj/portage pkgcheck scan app-benchmarks/gputest
```

Run pkgcheck to check for QA issues.

### Building packages

```bash
export PORTDIR_OVERLAY=/home/boyle/proj/portage

# Generate manifest (checksums)
ebuild ./pkg-1.0.ebuild manifest

# Full build cycle
ebuild ./pkg-1.0.ebuild clean unpack compile install

# Build from clean (removes work dir first)
ebuild ./pkg-1.0.ebuild clean && ebuild ./pkg-1.0.ebuild unpack prepare compile

# Individual phases
ebuild ./pkg-1.0.ebuild unpack   # Extract source
ebuild ./pkg-1.0.ebuild prepare  # Apply patches, run src_prepare
ebuild ./pkg-1.0.ebuild compile  # Build (usually no-op for binary)
ebuild ./pkg-1.0.ebuild install  # Install to staging dir
```

## Code Style Guidelines

### Ebuild Structure

- **EAPI**: Use `EAPI=8` (current stable)
- **Quotes**: Always quote variables: `"${S}"` not `${S}`
- **Newline**: End file with trailing newline
- **Executable**: Never set executable bit on `files/*` helpers
- **$PV**: Do NOT set manually - derived from filename

### Variables

```bash
# Good
S="${WORKDIR}/package-${PV}"
DOCS="README.md CHANGELOG.md"

# Avoid
S=${WORKDIR}/package-${PV}   # Unquoted
```

### Python Packages

- Use `python-single-r1` for packages that need Python runtime
- Use `python-any-r1` for packages that only build with Python
- Set `PYTHON_COMPAT=( python3_{10..14} )` or current supported versions
- Add `${PYTHON_DEPS}` to RDEPEND for runtime deps

```bash
PYTHON_COMPAT=( python3_{10..14} )
inherit python-single-r1

DEPEND="..."
RDEPEND="... ${PYTHON_DEPS}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
```

### Patches

- Place patches in `files/` directory
- Use `PATCHES` array to apply automatically:

```bash
PATCHES=( "${FILESDIR}/fix-build.patch" )
```

### Creating Patches

To create a clean patch that applies without fuzz:

1. Unpack the source:
   ```bash
   sudo rm -rf /var/tmp/portage/category/pkg-ver
   export PORTDIR_OVERLAY=/home/boyle/proj/portage
   ebuild ./category/pkg/pkg-ver.ebuild clean unpack
   ```

2. Copy the original file with `.orig` extension:
   ```bash
   cp path/to/file path/to/file.orig
   ```

3. Modify `path/to/file` with your intended fix (do NOT modify the `.orig` file)

4. Generate the diff:
   ```bash
   diff -u path/to/file.orig path/to/file
   ```

5. Edit the diff output to create the patch file:
   - Change `a/path/to/file` to `a/linux/` (or appropriate relative path)
   - Change `b/path/to/file` to `b/linux/`  
   - Or use `--strip=1` equivalent paths

6. Test the patch:
   ```bash
   mkdir -p /tmp/patch-test
   cp path/to/file.orig /tmp/patch-test/linux/my_application.cc
   cd /tmp/patch-test
   patch -p1 < /home/boyle/proj/portage/category/pkg/files/your-patch.patch
   # Verify only intended changes were applied
   diff /tmp/patch-test/linux/my_application.cc path/to/file
   ```

### RESTRICT Flags

- `RESTRICT="test"` - Package has no tests
- `RESTRICT="strip"` - Prebuilt binary (don't strip)
- `RESTRICT="primaryuri"` - Only fetch from SRC_URI (for .deb files)

### Common Issues to Avoid

1. **Missing Python eclass**: Don't use raw `dev-lang/python:3.x`, use eclass
2. **Unquoted variables**: Always quote `${S}`, `${FILESDIR}`, `${D}`
3. **Executable files**: `files/` helpers should not be executable
4. **Duplicate class definitions**: Check patched Python scripts for dupes

### Category Selection

- Use existing Gentoo categories from `/var/db/repos/gentoo/profiles/categories`
- Common: `dev-lang`, `media-video`, `dev-util`, `sci-electronics`, `app-benchmarks`

## Repository Structure

```
portage/
├── metadata/
│   └── layout.conf    # masters = gentoo, thin-manifests
├── profiles/
│   └── repo_name      # "boyle"
├── category/
│   └── package/
│       ├── Manifest   # checksums (auto-generated)
│       └── package-version.ebuild
└── files/             # Patches and helper scripts
```

## Reference Links

- https://devmanual.gentoo.org/ebuild-writing/index.html
- https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds
- https://wiki.gentoo.org/wiki/Writing_Rust_ebuilds
- Skeleton ebuild: `/var/db/repos/gentoo/skel.ebuild`

## Known Issues

- **yosys**: gcc-15 warnings (`Wmaybe-uninitialized`, `Warray-bounds`) in upstream code.
- **clgpustress**: Hardcoded OpenCL include path in Makefile (`/home/mat/docs/...`).
- **gputest**: Patch warning "patch unexpectedly ends in middle of line" (minor fuzz, still applies).

## Utility Scripts

### check-updates

Checks for upstream updates of packages in the overlay.

```bash
./bin/check-updates                    # Run check
./bin/check-updates -p 4              # With 4 parallel requests
./bin/check-updates --clear-cache      # Clear API cache
```

Output format: `<icon> <package>: <upstream-version> [(installed <ver>)][(ebuild <ver>)]`

| Icon | Meaning | Action |
|------|---------|--------|
| (blank) | Up to date | None |
| `↑` | Update available | `emerge pkg` |
| `+` | Ebuild needs update | Create/update ebuild |
| `o` | Not installed | `emerge pkg` |
| `?` | Non-GitHub source | Manual check |
| `!` | API error | Investigate |
| `~` | Anomaly detected | Warning |

Example output:
```
  ollama:         0.18.2
+ obsidian:       1.12.4 (installed 1.6.7)
↑ verilator:      5.046 (installed 5.044)
? gputest:
! unknown-pkg:
~ broken-pkg:     2.0.0 (WARNING: ebuild 1.0.0 is behind installed)
```
