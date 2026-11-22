#!/usr/bin/env python3
"""Test builder source and distribution against Luau mocks, not Roblox."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
runner = os.environ.get("LUA", "luau")
harness = (root / "tests/builder_mock.luau").read_text(encoding="utf-8")
for name in ("FrontlinesBuilder.client.lua", "FrontlinesBuilder.obfuscated.lua"):
    source = (root / "src" / name).read_text(encoding="utf-8")
    with tempfile.TemporaryDirectory() as directory:
        test = Path(directory) / "test.luau"
        test.write_text(harness.replace("-- INSERT_SOURCE_HERE", source), encoding="utf-8")
        print(name, flush=True)
        subprocess.run([runner, str(test)], check=True)
