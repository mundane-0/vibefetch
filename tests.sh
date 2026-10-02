#!/usr/bin/env bash
# Vibefetch regression suite — run before every release: bash tests.sh
set -u
cd "$(dirname "$0")"
pass=0; fail=0

check() { # check <description> <command...>
    local desc="$1"; shift
    if "$@" >/dev/null 2>&1; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL: $desc"; fi
}

# 1. Syntax
check "bash syntax" bash -n vibefetch.sh

# 2. Full matrix: 6 colors x 6 presets x 3 sizes = 108 combos
for c in inir ocean dracula cyberpunk forest vaporwave; do
  for p in classic boxes dots block full nano; do
    for s in compact normal large; do
      out=$(bash vibefetch.sh -c "$c" -p "$p" -s "$s" 2>&1); rc=$?
      if [ $rc -ne 0 ] || [ -z "$out" ]; then fail=$((fail+1)); echo "FAIL: matrix $c/$p/$s"; else pass=$((pass+1)); fi
    done
  done
done

# 3. Error handling must exit 1
for bad in "-p" "-c" "-s" "-p bogus" "-c bogus" "-s bogus" "-x"; do
  bash vibefetch.sh $bad >/dev/null 2>&1 && { fail=$((fail+1)); echo "FAIL: '$bad' should exit 1"; } || pass=$((pass+1))
done

# 4. Valid shortcuts must exit 0
check "--help" bash vibefetch.sh --help
check "help alias" bash vibefetch.sh help
check "--preview" bash vibefetch.sh --preview
check "--detect-env" bash vibefetch.sh --detect-env

# 5. Startup lifecycle (bash): enable -> re-enable (no dup) -> disable (clean)
t=$(mktemp -d)
HOME="$t" SHELL=/bin/bash bash vibefetch.sh --enable-startup >/dev/null 2>&1
HOME="$t" SHELL=/bin/bash bash vibefetch.sh --enable-startup >/dev/null 2>&1
n=$(grep -c "VIBEFETCH AUTO-START ---" "$t/.bashrc" 2>/dev/null || echo 0)
[ "$n" = "1" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: re-enable duplicated hook ($n)"; }
HOME="$t" SHELL=/bin/bash bash vibefetch.sh --disable-startup >/dev/null 2>&1
n=$(grep -c "VIBEFETCH" "$t/.bashrc" 2>/dev/null || echo 0)
[ "$n" = "0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: disable left $n hooks"; }
rm -rf "$t"

# 6. Startup lifecycle (fish)
t=$(mktemp -d)
HOME="$t" SHELL=/usr/bin/fish bash vibefetch.sh --enable-startup >/dev/null 2>&1
f="$t/.config/fish/config.fish"
grep -q "command -v vibefetch" "$f" 2>/dev/null && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: fish hook not guarded"; }
HOME="$t" SHELL=/usr/bin/fish bash vibefetch.sh --disable-startup >/dev/null 2>&1
n=$(grep -c "VIBEFETCH" "$f" 2>/dev/null || echo 0)
[ "$n" = "0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: fish disable left $n hooks"; }
rm -rf "$t"

# 7. Legacy orphan purge (old unguarded marker format)
t=$(mktemp -d)
printf '# --- VIBEFETCH START ---\nvibefetch\n# --- VIBEFETCH END ---\n' > "$t/.bashrc"
HOME="$t" SHELL=/bin/bash bash vibefetch.sh --disable-startup >/dev/null 2>&1
n=$(grep -c "VIBEFETCH" "$t/.bashrc" 2>/dev/null || echo 0)
[ "$n" = "0" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL: legacy hook survived ($n)"; }
rm -rf "$t"

echo ""
echo "Results: $pass passed, $fail failed"
[ "$fail" -eq 0 ] && echo "✅ ALL GREEN" || exit 1
