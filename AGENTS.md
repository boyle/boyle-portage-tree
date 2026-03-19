# AGENTS.md - portage

Gentoo overlay containing ebuilds for various tools.

## Current Packages

| Package | Category | Type | Description |
|---------|----------|------|-------------|
| svls | sci-electronics | Cargo | SystemVerilog language server |
| viu | media-video | Cargo | Terminal image viewer |
| yosys | sci-electronics | Makefile | RTL synthesis framework |
| verilator | sci-electronics | Autotools | Verilog/SystemVerilog simulator |
| opencode-bin | dev-util | Binary | AI coding agent |
| obsidian | app-text | Deb | Markdown knowledge base |
| ollama | sci-ml | Go | LLM runner |
| clgpustress | app-benchmarks | Makefile | OpenCL GPU stress test |
| gputest | app-benchmarks | Binary | GPU benchmark |
| ollama | acct-user | acct-user | Ollama service user |
| ollama | acct-group | acct-group | Ollama service group |

## Build/Lint/Test Commands

### Running pkgcheck (QA)

```bash
# Scan entire overlay
PORTDIR_OVERLAY=/home/boyle/proj/portage pkgcheck scan

# Scan specific package
PORTDIR_OVERLAY=/home/boyle/proj/portage pkgcheck scan app-benchmarks/gputest
```

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

REQUIRED_USE="^^ ( ${PYTHON_REQUIRED_USE} )"
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

## Pending Work

### pkgcheck Issues (from `pkgcheck scan`)

| Package | Issue | Priority |
|---------|-------|----------|
| opencode-bin | RedundantVersion (1.2.20 overshadowed by 1.2.26) | Medium |
| obsidian | DoubleEmptyLine (line 42) | Low |
| ollama | UnknownUseFlags (mkl, rocm) | Medium |
| acct-group/ollama | UnnecessaryManifest, PotentialStable | Low |
| acct-user/ollama | UnnecessaryManifest, PotentialStable | Low |
| clgpustress | NonsolvableDepsInDev/Stable (x86 deps issue) | High |
| repo | UnusedEclasses (alternatives-2, npmv1, numeric) | Low |
| eclass | Doc errors in custom eclasses | Low |

### Version Updates Needed

| Package | Current | Latest |
|---------|---------|--------|
| opencode-bin | 1.2.26 | Check GitHub |
| ollama | 0.17.7 | Check GitHub |