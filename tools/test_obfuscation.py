#!/usr/bin/env python3
"""Exercise both scripts against identical Luau mocks (not a Roblox integration test)."""
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(__file__).resolve().parent.parent
luau = os.environ.get("LUAU", "luau")
harness = (root / "tests/hub_mock.luau").read_text(encoding="utf-8")
for name in ("HolaHub.client.lua", "HolaHub.obfuscated.lua"):
    script = (root / "src" / name).read_text(encoding="utf-8")
    text = harness.replace("-- INSERT_SOURCE_HERE", script)
    with tempfile.TemporaryDirectory() as folder:
        testfile = Path(folder) / "test.luau"
        testfile.write_text(text, encoding="utf-8")
        print(name, flush=True)
        subprocess.run([luau, str(testfile)], check=True)
