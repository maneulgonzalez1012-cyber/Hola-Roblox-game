#!/usr/bin/env python3
"""Genera el distriburable con codificación reversible de bytes (sin dependencias)."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "src" / "HolaHub.client.lua"
OUTPUT = ROOT / "src" / "HolaHub.obfuscated.lua"


def encode(source: bytes) -> bytes:
    return bytes((byte + 91 + 13 * (index + 1)) % 256 for index, byte in enumerate(source))


def decode(encoded: bytes) -> bytes:
    return bytes((byte - 91 - 13 * (index + 1)) % 256 for index, byte in enumerate(encoded))


def build(source: bytes) -> str:
    encoded = encode(source)
    assert decode(encoded) == source
    # Escapes decimales de exactamente tres dígitos son válidos en Luau.
    chunks = ['"' + ''.join(f'\\{b:03d}' for b in encoded[i:i + 256]) + '"'
              for i in range(0, len(encoded), 256)]
    return (
        '-- Hola Hub: distribucion codificada; generada con tools/obfuscate.py.\n'
        'local _a=table.concat({' + ','.join(chunks) + '});'
        'local _b={};for _i=1,#_a do '
        '_b[_i]=string.char((string.byte(_a,_i)-91-13*_i)%256) end;'
        'local _f,_e=loadstring(table.concat(_b));'
        'assert(_f,_e);return _f()\n'
    )


if __name__ == "__main__":
    OUTPUT.write_text(build(SOURCE.read_bytes()), encoding="utf-8")
    print(f"Generado: {OUTPUT.relative_to(ROOT)}")
