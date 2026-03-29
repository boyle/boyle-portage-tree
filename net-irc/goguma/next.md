# Flutter Ebuild - Summary

## Goal
Build goguma (a Flutter app) in an isolated/offline environment where network access is restricted. All dependencies must be fetched via SRC_URI so they are captured in the Manifest.

## Background
- Goguma is an IRC client built with Flutter/Dart
- Flutter apps have many dependencies from pub.dev (Dart package registry)
- Network access is blocked in the target environment
- Need to bundle all Dart dependencies in SRC_URI

## Plan
1. Create a `flutter.eclass` similar to `cargo.eclass`
2. Define `FLUTTER_PUB_DEPS` variable with package@version pairs
3. Eclass generates `FLUTTER_PUB_URIS` for SRC_URI
4. Eclass provides `flutter_src_unpack()` to extract packages to pub cache

## Current State

### Flutter Eclass (`/home/boyle/proj/portage/eclass/flutter.eclass`)
- ✅ FLUTTER_PUB_DEPS variable for dependencies
- ✅ _flutter_set_pub_uris() generates URLs from deps
- ✅ FLUTTER_PUB_URIS variable for SRC_URI
- ✅ flutter_src_unpack() extracts packages to pub cache

### Goguma Ebuild (`/home/boyle/proj/portage/net-irc/goguma/goguma-0.9.1.ebuild`)
- ✅ Uses FLUTTER_PUB_DEPS with 174 packages (name@version format)
- ✅ SRC_URI includes ${FLUTTER_PUB_URIS}
- ✅ src_unpack() calls flutter_src_unpack()
- ❌ Build fails - flutter_lints not found in cache

## What We've Learned

1. **SRC_URI filename format**: Packages downloaded from pub.dev can have `+` in version numbers. The URL uses stripped version, but the file should be renamed for uniqueness.

2. **Cargo eclass approach**: Uses `name-version.crate` format; our eclass uses similar approach with `name-version.tar.gz`.

3. **Default unpack issue**: Portage's `default` in src_unpack() unpacks ALL tar.gz files in DISTDIR, not just the main sources. Need to override src_unpack() entirely.

4. **FLUTTER_PUB_DEPS whitespace**: The multiline variable has leading tabs, must strip them in the loop.

5. **PUB_CACHE structure**: Flutter looks for packages in `${PUB_CACHE}/hosted/pub.dev/{package}-{version}/`

## Current Issues

### Issue: flutter_lints not found
- Build fails with "could not find package flutter_lints in cache"
- flutter_lints IS in FLUTTER_PUB_DEPS
- flutter_lints-6.0.0.tar.gz IS in distdir
- flutter_lints is extracted to pub cache (seen in debug output)
- But something is wrong - only 59 packages in pub-cache after 167 should be there

### Issue: Package extraction not working correctly
- After `flutter_src_unpack()` runs, only ~59 packages are in the pub cache
- Should have ~167 packages (174 - some filtered)
- Something in the extraction is failing silently

## Next Steps

1. Debug why most packages aren't being extracted to pub cache
2. Check if `flutter_src_unpack()` is running correctly after src_unpack()
3. Remove debug einfo statements once working

## Reference

- Gentoo cargo.eclass: `/var/db/repos/gentoo/eclass/cargo.eclass`
- Pub.dev API: `https://pub.dev/api/archives/{package}-{version}.tar.gz`
- Pub cache structure: `${PUB_CACHE}/hosted/pub.dev/{package}-{version}/`
