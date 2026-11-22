#!/usr/bin/env python3
"""Run the VANTA Players source and distribution against mock Roblox APIs."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
runner = os.environ.get("LUA", "luau")
harness = (root / "tests/players_mock.luau").read_text(encoding="utf-8")
for name in ("VantaPlayers.client.lua", "VantaPlayers.obfuscated.lua"):
    source = (root / "src" / name).read_text(encoding="utf-8")
    with tempfile.TemporaryDirectory() as directory:
        script = Path(directory) / "test.luau"
        script.write_text(harness.replace("-- INSERT_SOURCE_HERE", source), encoding="utf-8")
        print(name, flush=True)
        subprocess.run([runner, str(script)], check=True)
