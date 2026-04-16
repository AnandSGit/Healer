# Spec: Karpathy Principles Integration (v9.0.0)

**Date:** 2026-04-15
**Design:** docs/designs/2026-04-15-karpathy-integration.md
**Brainstorm:** ~/.healer/brainstorms/2026-04-15-karpathy-in-healer.md
**Research:** ~/.healer/research/2026-04-15-karpathy-in-healer.md

---

## Requirement Traceability (from brainstorm)

| REQ | Description | Deliverable | Acceptance Test |
|-----|-------------|-------------|-----------------|
| REQ-F01 | P2 Simplicity HARD-GATE | _enforcement.md | AT-01 |
| REQ-F02 | P3 Surgical HARD-GATE | _enforcement.md | AT-02 |
| REQ-F03 | P1 enhancement (surface tradeoffs) | _enforcement.md | AT-03 |
| REQ-F04 | P4 documented as covered | _enforcement.md | AT-04 |
| REQ-F05 | /healer:karpathy command | commands/karpathy.md | AT-07 |
| REQ-F06 | Karpathy anti-rationalization entries | _enforcement.md | AT-05 |
| REQ-F07 | Karpathy red-flag entries | _enforcement.md | AT-06 |
| REQ-F08 | Flow gate integration | flow.md | AT-09 |
| REQ-F09 | Command-type scoping | SCOPE clause | AT-01, AT-02 |
| REQ-F10 | commands.yaml entry | data/commands.yaml | AT-08 |
| REQ-F11 | help-index rebuilt | data/help-index.json | AT-14 |
| REQ-F12 | Flow presets | flow.md | AT-09, AT-10 |
| REQ-NF01 | enforcement.md < 800 lines | _enforcement.md | AT-12 |
| REQ-NF02 | No regression in existing commands | commands/ | AT-13 |
| REQ-NF03 | P2/P3 dormant for ideation | SCOPE clause | AT-01, AT-02 |
| REQ-NF04 | Research-augmented karpathy | commands/karpathy.md | manual |
| REQ-C01 | Follow command structure | commands/karpathy.md | AT-07 |
| REQ-C02 | Artifact traceability | all docs | this file |
| REQ-C03 | Rebuild help-index | scripts/ | AT-14 |
| REQ-C04 | Version bump to 9.0.0 | plugin.json | AT-11 |
| REQ-C05 | P2 heuristic test | _enforcement.md | AT-01 |
| REQ-C06 | P3 traceback test | _enforcement.md | AT-02 |
| REQ-C07 | Phase-level scoping for mixed commands | SCOPE clause | AT-01, AT-02 |

---

## Acceptance Tests

### AT-01: P2 HARD-GATE exists and is scoped
```bash
grep "Simplicity Protocol" shared/_enforcement.md && grep "SCOPE:" shared/_enforcement.md
```
Pass: both return matches

### AT-02: P3 HARD-GATE exists and is scoped
```bash
grep "Surgical Changes Protocol" shared/_enforcement.md && grep "TRACEBACK TEST" shared/_enforcement.md
```
Pass: both return matches

### AT-03: P1 enhancement present
```bash
grep -E "surface.*tradeoffs|multiple valid approaches|simpler approach" shared/_enforcement.md
```
Pass: at least one match in Research Protocol section

### AT-04: P4 documented as covered
```bash
grep "Karpathy P4" shared/_enforcement.md
```
Pass: match found near Verification Protocol

### AT-05: Anti-rationalization entries (5 new)
```bash
grep -c -E "abstraction will be reusable|config flag for future|clean up.*adjacent|proper architecture|configured later" shared/_enforcement.md
```
Pass: count >= 5

### AT-06: Red-flag entries (3 new)
```bash
grep -c -E "touches files not mentioned|abstraction for a single call site|formatting.*style.*unrelated" shared/_enforcement.md
```
Pass: count >= 3

### AT-07: /healer:karpathy command exists
```bash
test -f commands/karpathy.md && head -3 commands/karpathy.md | grep "description:"
```
Pass: file exists with valid frontmatter

### AT-08: Command in catalog
```bash
grep "^karpathy:" data/commands.yaml
```
Pass: entry exists with category: quality

### AT-09: Flow presets exist
```bash
grep "karpathy-review:" commands/flow.md && grep "karpathy-fix:" commands/flow.md
```
Pass: both found

### AT-10: Suggested-next graph updated
```bash
grep "karpathy" commands/flow.md
```
Pass: karpathy appears in suggested-next graph

### AT-11: Version bumped
```bash
grep '"version".*"9.0.0"' plugin.json
```
Pass: version is 9.0.0

### AT-12: Line budget respected
```bash
wc -l < shared/_enforcement.md
```
Pass: output < 800

### AT-13: No existing command files modified
```bash
git diff --name-only commands/ | grep -v karpathy.md
```
Pass: empty output (only karpathy.md is new/modified)

### AT-14: Help index rebuilt
```bash
grep "karpathy" data/help-index.json
```
Pass: karpathy entry present

### AT-15: Data files restored
```bash
test -f data/commands.yaml && test -f data/flows.yaml && echo "PASS"
```
Pass: outputs PASS
