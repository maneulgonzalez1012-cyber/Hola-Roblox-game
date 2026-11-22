#!/usr/bin/env python3
"""Exercise Prison Life source and distribution with mock Roblox APIs."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
runner = os.environ.get("LUA", "luau")
harness = (root / "tests/prisonlife_mock.luau").read_text(encoding="utf-8")
for name in ("PrisonLife.client.lua", "PrisonLife.obfuscated.lua"):
    source = (root / "src" / name).read_text(encoding="utf-8")
    with tempfile.TemporaryDirectory() as directory:
        test = Path(directory) / "test.luau"
        test.write_text(harness.replace("-- INSERT_SOURCE_HERE", source), encoding="utf-8")
        print(name, flush=True)
        subprocess.run([runner, str(test)], check=True)
