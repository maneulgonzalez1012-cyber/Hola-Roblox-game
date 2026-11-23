#!/usr/bin/env python3
"""Run Luau mock tests for VANTA Spy (source and obfuscated)."""
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
luau = os.environ.get("LUA") or os.environ.get("LUAU") or "luau"
harness = (root / "tests/vantaspy_mock.luau").read_text(encoding="utf-8")
asserts = (root / "tests/vantaspy_assert.luau").read_text(encoding="utf-8")

for target in [root / "src/VantaSpy.client.lua", root / "src/VantaSpy.obfuscated.lua"]:
    combined = Path("/tmp/vanta_spy_combined.luau")
    combined.write_text(
        harness + "\nlocal __fn = function(...)\n" + target.read_text(encoding="utf-8") + "\nend\n__fn()\n" + asserts,
        encoding="utf-8",
    )
    res = subprocess.run([luau, str(combined)], cwd=root, check=False)
    if res.returncode != 0:
        sys.exit(res.returncode)
    print("OK:", target.name)
