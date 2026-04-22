# Node.js 22 Upgrade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade the Firebase extension from Node.js 20 to Node.js 22 runtime.

**Architecture:** Three files need updating — `extension.yaml` (runtime declarations), `functions/package.json` (engines field), and version bump + changelog entry. No code logic changes required.

**Tech Stack:** Firebase Extensions, Cloud Functions (Node.js 22), YAML, JSON

---

### Task 1: Update runtime in extension.yaml and bump version

**Files:**
- Modify: `extension.yaml:5` (version bump 1.1.2 → 1.1.3)
- Modify: `extension.yaml:62` (runtime: nodejs20 → nodejs22)
- Modify: `extension.yaml:70` (runtime: nodejs20 → nodejs22)

- [ ] **Step 1: Update extension.yaml version and both runtime declarations**

Change line 5:
```yaml
version: 1.1.3
```

Change line 62:
```yaml
      runtime: nodejs22
```

Change line 70:
```yaml
      runtime: nodejs22
```

- [ ] **Step 2: Verify the changes look correct**

Run:
```bash
grep -n "runtime:\|^version:" extension.yaml
```

Expected output:
```
5:version: 1.1.3
62:      runtime: nodejs22
70:      runtime: nodejs22
```

---

### Task 2: Add engines field to functions/package.json

**Files:**
- Modify: `functions/package.json`

- [ ] **Step 1: Add engines field**

Add after the `"private": true` line (or before closing brace), so the file becomes:

```json
{
  "name": "auto-stop-firebase-ext",
  "main": "index.js",
  "type": "module",
  "engines": {
    "node": "22"
  },
  "dependencies": {
    "@google-cloud/billing": "^4.3.0",
    "@google-cloud/billing-budgets": "^5.2.0",
    "@google-cloud/functions-framework": "^3.3.0",
    "@google-cloud/pubsub": "^4.3.2",
    "@google-cloud/resource-manager": "^5.1.0",
    "@google-cloud/service-usage": "^3.2.0",
    "firebase-admin": "^11.5.0",
    "firebase-functions": "^4.7.0",
    "assert": "^2.1.0"
  },
  "devDependencies": {
    "eslint": "^8.15.1",
    "eslint-config-google": "^0.14.0",
    "eslint-plugin-import": "^2.25.4",
    "eslint-plugin-promise": "^6.0.0",
    "firebase-functions-test": "^3.1.1",
    "mocha": "^10.3.0"
  },
  "scripts": {
    "lint": "./node_modules/.bin/eslint --max-warnings=0 ..",
    "lint:fix": "./node_modules/.bin/eslint --max-warnings=0 --fix ..",
    "test": "mocha --reporter spec"
  },
  "private": true
}
```

- [ ] **Step 2: Verify engines field is present**

Run:
```bash
node -e "const p = JSON.parse(require('fs').readFileSync('functions/package.json','utf8')); console.log(p.engines);"
```

Expected output:
```
{ node: '22' }
```

---

### Task 3: Add CHANGELOG entry

**Files:**
- Modify: `CHANGELOG.md` (prepend new version section)

- [ ] **Step 1: Add new version entry at the top of CHANGELOG.md**

Insert before the existing `## Version 1.1.2` line:

```markdown
## Version 1.1.3

Release Date: 21 April 2026

- Updated runtime to NodeJS v22, due to v20 deprecation

```

- [ ] **Step 2: Verify changelog looks correct**

Run:
```bash
head -10 CHANGELOG.md
```

Expected output:
```
## Version 1.1.3

Release Date: 21 April 2026

- Updated runtime to NodeJS v22, due to v20 deprecation

## Version 1.1.2

Release Date: 9 September 2025
```

---

### Task 4: Commit

- [ ] **Step 1: Stage and commit all changes**

```bash
git add extension.yaml functions/package.json CHANGELOG.md
git commit -m "chore: upgrade runtime from nodejs20 to nodejs22

- Bump extension version to 1.1.3
- Update both Cloud Function runtimes in extension.yaml
- Add engines field to functions/package.json
- Add CHANGELOG entry"
```

- [ ] **Step 2: Verify commit**

Run:
```bash
git log --oneline -3
```

Expected: new commit at top referencing the nodejs22 upgrade.
