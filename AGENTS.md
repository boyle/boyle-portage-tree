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
| parsec | games-util | Deb | Game streaming |
| clgpustress | app-benchmarks | Makefile | OpenCL GPU stress test |
| gputest | app-benchmarks | Binary | GPU benchmark |
| ollama | acct-user | acct-user | Ollama service user |
| ollama | acct-group | acct-group | Ollama service group |

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
```

## Ebuild Development

### Ebuild Types

#### 1. Cargo/Rust Packages

```bash
EAPI=8

CRATES="
	crate1@1.0.0
	crate2@2.0.0
"

inherit cargo

DESCRIPTION="Tool description"
HOMEPAGE="https://github.com/user/repo"
SRC_URI="
	https://github.com/user/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="test"

QA_FLAGS_IGNORED="/usr/bin/${PN}"

src_install() {
	cargo_src_install
	einstalldocs
}
```

#### 2. Binary Packages (prebuilt)

```bash
EAPI=8

DESCRIPTION="Tool description"
HOMEPAGE="https://example.com"
SRC_URI="https://example.com/${P}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="x11-misc/xclip"
RESTRICT="strip"
QA_PREBUILT="usr/bin/${PN}"

src_install() {
	dobin ${PN}
}
```

#### 3. Deb Packages

```bash
EAPI=8
inherit unpacker

DESCRIPTION="Tool description"
SRC_URI="https://example.com/${P}.deb"
RESTRICT="primaryuri"

src_unpack() {
	unpack_deb ${A}
}

src_install() {
	cp -R usr/ "${D}/" || die "Could not copy."
}
```

### Key Decisions

#### RESTRICT="test"
- Use for packages without tests (Gentoo-recommended)
- Semantically means "this package has no tests"
- Reference: https://devmanual.gentoo.org/ebuild-writing/functions/src_test/index.html

#### RESTRICT="strip"
- Use for prebuilt binaries that should not be stripped

#### Category Selection
- Use **existing Gentoo categories**
- Check `/var/db/repos/gentoo/profiles/categories`
- Common: `dev-lang`, `media-video`, `dev-util`, `sci-electronics`

#### Getting CRATES List
1. Download source and Cargo.lock from GitHub release
2. Extract crate names and versions from Cargo.lock
3. Format as `name@version` one per line

### Ebuild Commands

```bash
# Set PORTDIR_OVERLAY to use this overlay
export PORTDIR_OVERLAY=~/proj/portage

# Generate manifest (creates checksums)
ebuild ./pkg-1.0.ebuild manifest

# Full build cycle
ebuild ./pkg-1.0.ebuild clean unpack compile install

# Test (if not restricted)
ebuild ./pkg-1.0.ebuild test
```

### Key Gentoo Paths

- **Portage tree**: `/var/db/repos/gentoo`
- **Distfiles**: `/var/cache/distfiles`
- **Build tmpdir**: `/var/tmp/portage`
- **Installed packages**: `/var/db/pkg`

## Testing Status

| Package | Status | Notes |
|---------|--------|-------|
| svls | ✓ Tested | Built successfully, 337s |
| viu | ✓ Tested | Built successfully, 69s |
| parsec | Pending | Deb package |
| clgpustress | Pending | Makefile build |
| gputest | Pending | Binary package |
| yosys | Pending | Complex LLVM build |
| verilator | Pending | Autotools build |
| opencode-bin | Pending | Binary package |
| obsidian | Pending | Deb package |
| ollama | Pending | Go + CUDA/ROCm |

## Reference Links

- https://devmanual.gentoo.org/ebuild-writing/index.html
- https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds
- https://wiki.gentoo.org/wiki/Writing_Rust_ebuilds
- Skeleton ebuild: `/var/db/repos/gentoo/skel.ebuild`

## Future Improvements

1. Test remaining packages (see Testing Status above)
2. Run pkgcheck QA scan
3. Consider adding CI workflow for pkgcheck
4. Keep KEYWORDS at ~amd64 until packages are stable
