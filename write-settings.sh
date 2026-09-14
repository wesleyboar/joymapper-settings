#!/usr/bin/env python3
"""Decodes a JoyMapper settings.bin into one JSON array on stdout, preserving
the original order of the printable strings in the file. Embedded JSON blobs
(mappings, device lists, etc.) are decoded to nested JSON rather than left as
escaped strings, so the whole file is one valid, diffable JSON document.

Fields whose values are raw binary (int64, bool, ...) aren't printable text,
so a placeholder is inserted after their type name instead of the value.

Used by sync-settings.sh; can also be run directly:
  ./write-settings.sh path/to/settings.bin
"""
import json
import re
import sys

STRING_RE = re.compile(rb"[\x20-\x7e]{4,}")

# Type names observed in this format whose values are raw binary (not
# printable text), so no value ever appears for them in the string stream.
NO_VISIBLE_VALUE_TYPES = {"int64", "int", "bool", "float64"}
PLACEHOLDER = "<binary value, not decoded>"


def try_parse_json(s: str):
    """Return (prefix, value) if s is prefix-bytes + a JSON value consuming
    the rest of s exactly, else None. prefix is '' when there's no prefix."""
    idx = min((i for i in (s.find("["), s.find("{")) if i != -1), default=-1)
    if idx == -1:
        return None
    prefix, rest = s[:idx], s[idx:]
    try:
        value, end = json.JSONDecoder().raw_decode(rest)
    except json.JSONDecodeError:
        return None
    if end != len(rest):
        return None
    return (prefix, value)


def main() -> None:
    with open(sys.argv[1], "rb") as f:
        data = f.read()

    tokens = []
    for m in STRING_RE.finditer(data):
        s = m.group().decode("ascii")
        parsed = try_parse_json(s)
        if parsed is None:
            tokens.append(s)
            if s in NO_VISIBLE_VALUE_TYPES:
                tokens.append(PLACEHOLDER)
        else:
            prefix, value = parsed
            if prefix:
                tokens.append(prefix)
            tokens.append(value)

    print(json.dumps(tokens, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
