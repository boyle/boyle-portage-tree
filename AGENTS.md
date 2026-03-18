# AGENTS.md - portage

Gentoo overlay containing ebuilds for various tools.

## Current Packages

| Package | Category | Description |
|---------|----------|-------------|
| svls | sci-electronics | SystemVerilog language server |
| viu | media-video | Terminal image viewer |
| yosys | sci-electronics | Synthesizer |
| verilator | sci-electronics | Verilog simulator |
| opencode-bin | dev-util | OpenCode binary |
| obsidian | app-text | Markdown editor |
| ollama | sci-ml | LLM runner |
| parsec | games-util | Gaming network tool |
| clgpustress | app-benchmarks | GPU stress test |
| gputest | app-benchmarks | GPU benchmark |

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

### Ebuild Template (Cargo/Rust packages)

```bash
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

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

### Key Decisions

#### RESTRICT="test"
- Use for packages without tests (Gentoo-recommended)
- Semantically means "this package has no tests"
- Reference: https://devmanual.gentoo.org/ebuild-writing/functions/src_test/index.html

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

## Reference Links

- https://devmanual.gentoo.org/ebuild-writing/index.html
- https://wiki.gentoo.org/wiki/Basic_guide_to_write_Gentoo_Ebuilds
- https://wiki.gentoo.org/wiki/Writing_Rust_ebuilds
- Skeleton ebuild: `/var/db/repos/gentoo/skel.ebuild`

## Future Improvements

1. Add more packages as needed
2. Consider adding pkgcheck QA checks to CI
3. Keep KEYWORDS at ~amd64 until packages are stable
