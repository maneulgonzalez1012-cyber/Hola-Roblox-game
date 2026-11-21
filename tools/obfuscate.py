#!/usr/bin/env python3
"""Generate the distribution with the pinned Obscura CLI and native Luau parser."""
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
cli = os.environ.get("OBSCURA_CLI")
parser = os.environ.get("OBSCURA_NATIVE_BIN")
if not cli or not parser:
    sys.exit("Set OBSCURA_CLI and OBSCURA_NATIVE_BIN; see README.md for setup.")
subprocess.run([
    "node", cli, "build", str(root / "src/HolaHub.client.lua"),
    "-o", str(root / "src/HolaHub.obfuscated.lua"),
    "--transforms", "rename,string,constant,dead-code",
    "--seed", "12345", "--verbose",
], check=True)
