#!/usr/bin/env python3
"""
This script verifies that our OCaml argon2 implementation is compatible
with the standard Python argon2-cffi library.
"""

import sys
from argon2 import PasswordHasher
from argon2.low_level import Type
import argon2


def generate_and_print_hash(password, time_cost=2, memory_cost=19456, parallelism=1):
    """Generate an argon2id hash using Python and print it."""
    ph = PasswordHasher(
        time_cost=time_cost,
        memory_cost=memory_cost,
        parallelism=parallelism,
        hash_len=32,
        salt_len=16,
        type=Type.ID,  # Argon2id
    )
    hash_str = ph.hash(password)
    print(f"Python generated hash: {hash_str}")
    return hash_str


def verify_hash(password, hash_str):
    """Verify a password against an argon2 hash."""
    ph = PasswordHasher()
    try:
        ph.verify(hash_str, password)
        return True
    except argon2.exceptions.VerifyMismatchError:
        return False
    except Exception as e:
        print(f"Error during verification: {e}")
        return False


def main():
    if len(sys.argv) < 2:
        print("Usage:")
        print(
            "  Generate: python verify_argon2.py generate <password> [time_cost] [memory_cost] [parallelism]"
        )
        print("  Verify:   python verify_argon2.py verify <password> <hash>")
        sys.exit(1)

    command = sys.argv[1]

    if command == "generate":
        if len(sys.argv) < 3:
            print("Error: password required")
            sys.exit(1)
        password = sys.argv[2]
        time_cost = int(sys.argv[3]) if len(sys.argv) > 3 else 2
        memory_cost = int(sys.argv[4]) if len(sys.argv) > 4 else 19456
        parallelism = int(sys.argv[5]) if len(sys.argv) > 5 else 1
        generate_and_print_hash(password, time_cost, memory_cost, parallelism)

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
