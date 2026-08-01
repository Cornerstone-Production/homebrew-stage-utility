# Security Policy

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Report vulnerabilities privately through GitHub's
[**Private vulnerability reporting**](https://github.com/Cornerstone-Production/homebrew-stage-utility/security/advisories/new)
(Security → Advisories → "Report a vulnerability").

## What this repository is

A [Homebrew](https://brew.sh) tap holding a single formula. The formula is
**generated** by the Stage Utility release workflow and pushed here — it is not
edited by hand, and a change made directly to it will be overwritten by the next
release.

The formula installs a prebuilt archive from a
[Stage Utility release](https://github.com/Cornerstone-Production/Stage-Utility/releases).
Each archive's SHA-256 is pinned in the formula, so Homebrew refuses to install a
download that does not match what was published.

- **Reportable here:** a formula pinning the wrong checksum or the wrong URL, or
  anything that would cause `brew install` to fetch something other than the
  published release.
- **Belongs upstream:** vulnerabilities in Stage Utility itself go to
  [Stage-Utility](https://github.com/Cornerstone-Production/Stage-Utility/security/advisories/new).
