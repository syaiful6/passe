#!/usr/bin/env bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo -e "${BLUE}Building OCaml verification tool...${NC}"
dune build example/verify.exe

VERIFY_OCAML="_build/default/example/verify.exe"
VERIFY_BCRYPT_PY="python3 example/verify_bcrypt.py"
VERIFY_ARGON2_PY="python3 example/verify_argon2.py"

TOTAL_TESTS=0
PASSED_TESTS=0

test_case() {
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  if "$@"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
    echo -e "${GREEN}✓ PASS${NC}"
    return 0
  else
    echo -e "${RED}✗ FAIL${NC}"
    return 1
  fi
}

echo ""
echo -e "${BLUE}=== Bcrypt Cross-Verification ===${NC}"
echo ""

echo "Test 1: OCaml generates bcrypt hash, Python verifies"
HASH=$($VERIFY_OCAML bcrypt generate "test123" 4 | grep "OCaml generated hash:" | cut -d' ' -f4)
echo "  Hash: $HASH"
test_case $VERIFY_BCRYPT_PY verify "test123" "$HASH"

echo ""
echo "Test 2: Python generates bcrypt hash, OCaml verifies"
HASH=$($VERIFY_BCRYPT_PY generate "hello world" 4 | grep "Python generated hash:" | cut -d' ' -f4)
echo "  Hash: $HASH"
test_case $VERIFY_OCAML bcrypt verify "hello world" "$HASH"

echo ""
echo "Test 3: Known bcrypt test vector (Python verify)"
KNOWN_HASH='$2b$04$EGdrhbKUv8Oc9vGiXX0HQOxSg445d458Muh7DAHskb6QbtCvdxcie'
test_case $VERIFY_BCRYPT_PY verify "correctbatteryhorsestapler" "$KNOWN_HASH"

echo ""
echo "Test 4: Known bcrypt test vector (OCaml verify)"
test_case $VERIFY_OCAML bcrypt verify "correctbatteryhorsestapler" "$KNOWN_HASH"

echo ""
echo -e "${BLUE}=== Argon2 Cross-Verification ===${NC}"
echo ""

echo "Test 5: OCaml generates argon2 hash, Python verifies"
HASH=$($VERIFY_OCAML argon2 generate "test123" 2 4096 1 | grep "OCaml generated hash:" | cut -d' ' -f4)
echo "  Hash: $HASH"
test_case $VERIFY_ARGON2_PY verify "test123" "$HASH"

echo ""
echo "Test 6: Python generates argon2 hash, OCaml verifies"
HASH=$($VERIFY_ARGON2_PY generate "hello world" 2 4096 1 | grep "Python generated hash:" | cut -d' ' -f4)
echo "  Hash: $HASH"
test_case $VERIFY_OCAML argon2 verify "hello world" "$HASH"

echo ""
echo "Test 7: Special characters (OCaml→Python)"
HASH=$($VERIFY_OCAML argon2 generate "P@ssw0rd!" 2 4096 1 | grep "OCaml generated hash:" | cut -d' ' -f4)
test_case $VERIFY_ARGON2_PY verify "P@ssw0rd!" "$HASH"

echo ""
echo "Test 8: Special characters (Python→OCaml)"
HASH=$($VERIFY_ARGON2_PY generate "€uro$£¥" 2 4096 1 | grep "Python generated hash:" | cut -d' ' -f4)
test_case $VERIFY_OCAML argon2 verify "€uro$£¥" "$HASH"

echo ""
echo -e "${BLUE}=== Summary ===${NC}"
echo "Total tests: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
  echo -e "${GREEN}All cross-verification tests passed! ✓${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi
