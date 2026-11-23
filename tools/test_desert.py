#!/usr/bin/env python3
"""Test Desert Detectors source and distribution against Roblox mocks."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
harness = (root / "tests/desert_mock.luau").read_text(encoding="utf-8")
for name in ("DesertDetectors.client.lua", "DesertDetectors.obfuscated.lua"):
    source = (root / "src" / name).read_text(encoding="utf-8")
    with tempfile.TemporaryDirectory() as folder:
        test = Path(folder) / "test.luau"
        test.write_text(harness.replace("-- INSERT_SOURCE_HERE", source), encoding="utf-8")
        print(name, flush=True)
        subprocess.run([os.environ.get("LUA", "luau"), str(test)], check=True)
