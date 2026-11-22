#!/usr/bin/env python3
"""Build the selected distribution. See README for pinned tool versions."""
import argparse
import os
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parent.parent
arguments = argparse.ArgumentParser()
arguments.add_argument("--break-in", action="store_true", help="Build Break In with Prometheus")
choice = arguments.parse_args()
if choice.break_in:
    prometheus = os.environ.get("PROMETHEUS_DIR")
    luajit = os.environ.get("LUAJIT")
    if not prometheus or not luajit:
        sys.exit("Set PROMETHEUS_DIR and LUAJIT; see README.md for setup.")
    output = root / "src/BreakIn.obfuscated.lua"
    subprocess.run([
        luajit, str(Path(prometheus) / "cli.lua"),
        "--config", str(root / "tools/prometheus_breakin.lua"), "--LuaU", "--nocolors",
        "--out", str(output), str(root / "src/BreakIn.client.lua"),
    ], cwd=prometheus, check=True)
    credit = "-- Based on Prometheus by Elias Oelschner, https://github.com/prometheus-lua/Prometheus\n"
    output.write_text(credit + output.read_text(encoding="utf-8"), encoding="utf-8")
else:
    cli = os.environ.get("OBSCURA_CLI")
    if not cli or not os.environ.get("OBSCURA_NATIVE_BIN"):
        sys.exit("Set OBSCURA_CLI and OBSCURA_NATIVE_BIN; see README.md for setup.")
    subprocess.run([
        "node", cli, "build", str(root / "src/HolaHub.client.lua"),
        "-o", str(root / "src/HolaHub.obfuscated.lua"),
        "--transforms", "rename,string,constant,dead-code",
        "--seed", "12345", "--verbose",
    ], check=True)
