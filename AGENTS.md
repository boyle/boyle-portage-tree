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
./bin/check-updates
```

Output format:
```
package: <upstream-version> (<status>)
```

Status can be: `(up to date)`, `(<installed-version>, installed)`, or `(not installed)`.
