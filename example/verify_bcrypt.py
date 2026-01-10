#!/usr/bin/env python3
"""
This script verifies that our OCaml bcrypt implementation is compatible
with the standard Python bcrypt library.
"""

import sys
import bcrypt


def generate_and_print_hash(password, cost=4):
    """Generate a bcrypt hash using Python and print it."""
    pwd_bytes = password.encode("utf-8")
    salt = bcrypt.gensalt(rounds=cost)
    hash_bytes = bcrypt.hashpw(pwd_bytes, salt)
    hash_str = hash_bytes.decode("utf-8")
    print(f"Python generated hash: {hash_str}")
    return hash_str


def verify_hash(password, hash_str):
    """Verify a password against a bcrypt hash."""
    pwd_bytes = password.encode("utf-8")
    hash_bytes = hash_str.encode("utf-8")
    result = bcrypt.checkpw(pwd_bytes, hash_bytes)
    return result


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print("  Generate: python verify_bcrypt.py generate <password> [cost]")
        print("  Verify:   python verify_bcrypt.py verify <password> <hash>")
        sys.exit(1)

    command = sys.argv[1]

    if command == "generate":
        if len(sys.argv) < 3:
            print("Error: password required")
            sys.exit(1)
        password = sys.argv[2]
        cost = int(sys.argv[3]) if len(sys.argv) > 3 else 4
        generate_and_print_hash(password, cost)

    elif command == "verify":
        if len(sys.argv) < 4:
            print("Error: password and hash required")
            sys.exit(1)
        password = sys.argv[2]
        hash_str = sys.argv[3]

        result = verify_hash(password, hash_str)
        if result:
            print("✓ Verification successful")
            sys.exit(0)
        else:
            print("✗ Verification failed")
            sys.exit(1)

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
