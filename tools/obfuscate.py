#!/usr/bin/env python3
"""Generate the distribution with the pinned Obscura CLI and native Luau parser."""
import argparse
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
cli = os.environ.get("OBSCURA_CLI")
parser = os.environ.get("OBSCURA_NATIVE_BIN")
if not cli or not parser:
    sys.exit("Set OBSCURA_CLI and OBSCURA_NATIVE_BIN; see README.md for setup.")
arguments = argparse.ArgumentParser()
arguments.add_argument("--break-in", action="store_true", help="Build the Break In script instead of Blade Ball")
choice = arguments.parse_args()
name = "BreakIn" if choice.break_in else "HolaHub"
subprocess.run([
    "node", cli, "build", str(root / f"src/{name}.client.lua"),
    "-o", str(root / f"src/{name}.obfuscated.lua"),
    "--transforms", "rename,string,constant,dead-code",
    "--seed", "12345", "--verbose",
], check=True)
