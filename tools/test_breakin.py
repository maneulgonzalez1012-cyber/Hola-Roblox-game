#!/usr/bin/env python3
"""Run Break In's client against mock Roblox APIs (not an in-game test)."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
runner = os.environ.get("LUA", "luau")
harness = (root / "tests/breakin_mock.lua").read_text(encoding="utf-8")
for name in ("BreakIn.client.lua", "BreakIn.obfuscated.lua"):
    source = (root / "src" / name).read_text(encoding="utf-8")
    with tempfile.TemporaryDirectory() as directory:
        script = Path(directory) / "test.lua"
        script.write_text(harness.replace("-- INSERT_SOURCE_HERE", source), encoding="utf-8")
        print(name, flush=True)
        subprocess.run([runner, str(script)], check=True)
