#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURES="$SCRIPT_DIR/fixtures"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

fail() { echo "CLI fixture failed: $*" >&2; exit 1; }

"$ROOT/bin/session-brief" --help >/dev/null
"$ROOT/bin/pr-comments" --help >/dev/null
"$ROOT/bin/pr-review" --help >/dev/null
"$ROOT/bin/knowledge-query" --help >/dev/null
"$ROOT/bin/agent-audit" --help >/dev/null
"$ROOT/bin/opencode-profiles" --help >/dev/null

PATH="$FIXTURES/bin:$PATH" "$ROOT/bin/session-brief" --json "$ROOT" >"$TEMP_DIR/session.json"
jq -e '.path == "." and (.git.dirty | type == "boolean") and (.package.validation_commands | type == "array") and .open_pr == "https://github.com/citizenshipper/control-plane/pull/99"' \
  "$TEMP_DIR/session.json" >/dev/null
"$ROOT/bin/session-brief" "$ROOT" >"$TEMP_DIR/session.txt"
[ "$(wc -l <"$TEMP_DIR/session.txt" | tr -d ' ')" -le 6 ] || fail "session brief is not compact"
PATH="$FIXTURES/bin:$PATH" "$ROOT/bin/session-brief" --full "$ROOT" >"$TEMP_DIR/session-full.txt"
grep -qF 'Open PR: https://github.com/citizenshipper/control-plane/pull/99' "$TEMP_DIR/session-full.txt" || fail "full brief open PR missing"

"$ROOT/bin/pr-review" render "$FIXTURES/pr-context.json" "$FIXTURES/pr-findings.json" >"$TEMP_DIR/review.md"
grep -qF '### MEDIUM (1)' "$TEMP_DIR/review.md" || fail "review finding section missing"
grep -qF 'Failure is swallowed' "$TEMP_DIR/review.md" || fail "review title missing"
"$ROOT/bin/pr-review" render "$FIXTURES/pr-context.json" "$FIXTURES/pr-findings-empty.json" >"$TEMP_DIR/review-empty.md"
grep -qF 'No blocking issues.' "$TEMP_DIR/review-empty.md" || fail "empty review message missing"
if "$ROOT/bin/pr-review" render "$FIXTURES/pr-context.json" "$FIXTURES/does-not-exist.json" >/dev/null 2>&1; then
  fail "missing findings should fail"
fi

PATH="$FIXTURES/bin:$PATH" "$ROOT/bin/pr-comments" example 7 >"$TEMP_DIR/comments.txt"
grep -qF 'Recent feedback:' "$TEMP_DIR/comments.txt" || fail "compact comments missing"
if grep -qF 'Full fixture description' "$TEMP_DIR/comments.txt"; then fail "compact comments leaked full description"; fi
PATH="$FIXTURES/bin:$PATH" "$ROOT/bin/pr-comments" --raw example 7 >"$TEMP_DIR/comments.json"
jq -e '.pr.number == 7 and (.review_comments | length) == 1' "$TEMP_DIR/comments.json" >/dev/null

"$ROOT/bin/knowledge-query" --scope control-plane "OpenCode agent profile architecture" >"$TEMP_DIR/knowledge.txt"
grep -qF 'Traversal: BFS' "$TEMP_DIR/knowledge.txt" || fail "control-plane graph query did not run"
if grep -qF 'olympus::' "$TEMP_DIR/knowledge.txt"; then fail "control-plane query leaked product nodes"; fi
PATH="$FIXTURES/bin:$PATH" "$ROOT/bin/knowledge-query" --graph "$FIXTURES/graph.json" --scope example "service flow" >"$TEMP_DIR/knowledge-scoped.txt"
grep -qF 'Fixture scoped query:' "$TEMP_DIR/knowledge-scoped.txt" || fail "repo-scoped query did not run"
[ ! -e "$ROOT/tmp/knowledge-scope-example.json" ] || fail "repo-scoped query persisted a graph"
if "$ROOT/bin/knowledge-query" --graph "$TEMP_DIR/missing-graph.json" "missing graph" >"$TEMP_DIR/knowledge-missing.txt" 2>&1; then
  fail "missing Graphify graph should fail"
else
  [ "$?" -eq 3 ] || fail "missing Graphify graph should exit 3"
fi
grep -qF 'knowledge-bootstrap' "$TEMP_DIR/knowledge-missing.txt" || fail "missing graph repair command missing"

RELEASE_REMOTE="$TEMP_DIR/release-origin.git"
RELEASE_WORKTREE="$TEMP_DIR/release-worktree"
git init --quiet --bare "$RELEASE_REMOTE"
git init --quiet -b release/test "$RELEASE_WORKTREE"
git -C "$RELEASE_WORKTREE" config user.name Fixture
git -C "$RELEASE_WORKTREE" config user.email fixture@example.com
mkdir -p "$RELEASE_WORKTREE/k8s/daedalus"
printf 'image:\n  tag: target-sha\n' >"$RELEASE_WORKTREE/k8s/daedalus/values.staging.yaml"
printf 'image:\n  tag: target-sha\n' >"$RELEASE_WORKTREE/k8s/daedalus/values.production.yaml"
git -C "$RELEASE_WORKTREE" add .
git -C "$RELEASE_WORKTREE" commit --quiet -m fixture
git -C "$RELEASE_WORKTREE" remote add origin "$RELEASE_REMOTE"
git -C "$RELEASE_WORKTREE" push --quiet -u origin release/test
RELEASE_COMMIT=$(git -C "$RELEASE_WORKTREE" rev-parse HEAD)
RELEASE_FILES=$(printf '%s\n' 'k8s/daedalus/values.production.yaml' 'k8s/daedalus/values.staging.yaml')
export GH_RELEASE_FIXTURE=1
export GH_RELEASE_PR_URL='https://github.com/citizenshipper/ops/pull/123'
export GH_RELEASE_PR_TITLE='Release fixture'
export GH_RELEASE_PR_BRANCH='release/test'
export GH_RELEASE_PR_SHA="$RELEASE_COMMIT"
export GH_RELEASE_PR_FILES="$RELEASE_FILES"
(
  PATH="$FIXTURES/bin:$PATH"
  source "$ROOT/lib/release-common.sh"
  release_verify_postconditions "$RELEASE_WORKTREE" release/test "$RELEASE_COMMIT" "$GH_RELEASE_PR_URL" "$GH_RELEASE_PR_TITLE" "$RELEASE_FILES" target-sha
)
if (
  PATH="$FIXTURES/bin:$PATH"
  source "$ROOT/lib/release-common.sh"
  release_verify_postconditions "$RELEASE_WORKTREE" release/test 0000000000000000000000000000000000000000 "$GH_RELEASE_PR_URL" "$GH_RELEASE_PR_TITLE" "$RELEASE_FILES" target-sha
) >/dev/null 2>&1; then
  fail "release verification accepted a stale remote head"
fi
GH_RELEASE_PR_SHA=0000000000000000000000000000000000000000
export GH_RELEASE_PR_SHA
if (
  PATH="$FIXTURES/bin:$PATH"
  source "$ROOT/lib/release-common.sh"
  release_verify_postconditions "$RELEASE_WORKTREE" release/test "$RELEASE_COMMIT" "$GH_RELEASE_PR_URL" "$GH_RELEASE_PR_TITLE" "$RELEASE_FILES" target-sha
) >/dev/null 2>&1; then
  fail "release verification accepted an incorrect PR head"
fi
GH_RELEASE_PR_SHA="$RELEASE_COMMIT"
GH_RELEASE_PR_FILES=$(printf '%s\n' "$RELEASE_FILES" 'unexpected.yaml')
export GH_RELEASE_PR_SHA GH_RELEASE_PR_FILES
if (
  PATH="$FIXTURES/bin:$PATH"
  source "$ROOT/lib/release-common.sh"
  release_verify_postconditions "$RELEASE_WORKTREE" release/test "$RELEASE_COMMIT" "$GH_RELEASE_PR_URL" "$GH_RELEASE_PR_TITLE" "$RELEASE_FILES" target-sha
) >/dev/null 2>&1; then
  fail "release verification accepted unexpected PR files"
fi
GH_RELEASE_PR_FILES="$RELEASE_FILES"
export GH_RELEASE_PR_FILES
printf 'image:\n  tag: wrong-sha\n' >"$RELEASE_WORKTREE/k8s/daedalus/values.staging.yaml"
if (
  PATH="$FIXTURES/bin:$PATH"
  source "$ROOT/lib/release-common.sh"
  release_verify_postconditions "$RELEASE_WORKTREE" release/test "$RELEASE_COMMIT" "$GH_RELEASE_PR_URL" "$GH_RELEASE_PR_TITLE" "$RELEASE_FILES" target-sha
) >/dev/null 2>&1; then
  fail "release verification accepted an incorrect values tag"
fi
git -C "$RELEASE_WORKTREE" checkout --quiet -- k8s/daedalus/values.staging.yaml
unset GH_RELEASE_FIXTURE GH_RELEASE_PR_URL GH_RELEASE_PR_TITLE GH_RELEASE_PR_BRANCH GH_RELEASE_PR_SHA GH_RELEASE_PR_FILES

grep -qF 'without explicit user approval' "$ROOT/.opencode/commands/pr-review.md" || fail "quick review approval gate missing"
if "$ROOT/bin/pr-review" submit "https://github.com/citizenshipper/example/pull/42" "$FIXTURES/pr-findings.json" >/dev/null 2>&1; then
  fail "review submit accepted without approval flag"
fi

"$ROOT/bin/agent-audit" --json >"$TEMP_DIR/audit.json"
jq -e '.ok == true and .agents.words <= .agents.budget_words and .commands.words <= .commands.budget_words' \
  "$TEMP_DIR/audit.json" >/dev/null
"$ROOT/bin/opencode-profiles" --check --json >"$TEMP_DIR/profiles.json"
jq -e '.ok == true and .drift == []' "$TEMP_DIR/profiles.json" >/dev/null

echo "CLI fixtures: passed"
