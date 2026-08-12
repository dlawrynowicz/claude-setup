"""
Rewrap comments and docstrings so lines break at clause boundaries instead of wherever the
column limit falls.

Enforces the rule in skills/SHARED.md, "Comments and docstrings". That rule was written down long
before this tool existed and still got broken constantly, because judging a clause boundary by eye
on every edit does not happen. This makes it mechanical.

The rule, applied mechanically:
  1. Split the paragraph into clauses. A clause ends at `.` `;` `:` or `,`.
  2. Pack whole clauses onto a line while they fit.
  3. Word-wrap only a clause too long to fit on a line of its own.

An abbreviation's period never ends a clause. Indented blocks inside a docstring, such as usage
examples and field tables, are copied through untouched.

Python: docstrings and `#` runs. TypeScript and JavaScript: `/* */` and `/** */` blocks,
and `//` runs. JSDoc tag lines such as `@param` are left alone, since they are not prose.

By default only comments overlapping lines that differ from git HEAD are rewrapped, so editing one
function does not reflow comments elsewhere and pollute the diff. A file git does not know about is
rewrapped whole. `--all` overrides this.

    python wrap_comments.py FILE [--width 99] [--check] [--all]
"""

import argparse
import os
import re
import subprocess
import sys

ABBREVIATIONS = {
    "e.g.", "i.e.", "etc.", "vs.", "cf.", "approx.", "no.", "fig.", "al.",
    "Mr.", "Mrs.", "Ms.", "Dr.", "St.", "Inc.", "Ltd.", "Co.",
}
BOUNDARY_CHARS = ".;:,"


def ends_clause(word: str) -> bool:
    """True when a word can end a line: it closes on a boundary character and is not an abbreviation."""
    if word in ABBREVIATIONS:
        return False
    stripped = word.rstrip(")]}`\"'")
    return bool(stripped) and stripped[-1] in BOUNDARY_CHARS


def split_clauses(text: str) -> list:
    """
    The paragraph as chunks, each ending at a clause boundary apart from the last.

    A boundary inside a backticked code span does not count, so `update_or_create(lease,
    rental_option)` stays on one line.
    """
    clauses, current = [], []
    in_code = False
    for word in text.split():
        current.append(word)
        if word.count("`") % 2:
            in_code = not in_code
        if not in_code and ends_clause(word):
            clauses.append(" ".join(current))
            current = []
    if current:
        clauses.append(" ".join(current))
    return clauses


def hard_wrap(text: str, indent: str, width: int) -> list:
    """Plain word wrap, for a clause with no boundary inside the limit."""
    lines, line = [], ""
    for word in text.split():
        candidate = f"{line} {word}".strip()
        if line and len(indent) + len(candidate) > width:
            lines.append(indent + line)
            line = word
        else:
            line = candidate
    if line:
        lines.append(indent + line)
    return lines


def wrap_paragraph(text: str, indent: str, width: int) -> list:
    """Pack clauses onto lines so each line ends at a boundary whenever one fits."""
    lines, line = [], ""
    for clause in split_clauses(text):
        candidate = f"{line} {clause}".strip()
        if line and len(indent) + len(candidate) > width:
            lines.append(line)
            line = clause
        else:
            line = candidate
    if line:
        lines.append(line)
    return [wrapped for line in lines for wrapped in hard_wrap(line, indent, width)]


def is_prose(block: list, base_indent: int) -> bool:
    """Indented lines are usage examples or tables, so they are left as they are."""
    return all(
        not raw.strip() or len(raw) - len(raw.lstrip()) <= base_indent
        for raw in block
    )


def rewrap_docstring(body: list, indent: str, width: int) -> list:
    """Reflow each blank-line-separated prose paragraph, copying indented blocks through."""
    out: list = []
    paragraph: list = []

    def flush() -> None:
        if not paragraph:
            return
        if is_prose(paragraph, len(indent)):
            out.extend(wrap_paragraph(" ".join(p.strip() for p in paragraph), indent, width))
        else:
            out.extend(paragraph)
        paragraph.clear()

    for raw in body:
        if raw.strip():
            paragraph.append(raw)
        else:
            flush()
            out.append("")
    flush()
    return out


def rewrap_python(source: list, width: int) -> list:
    out: list = []
    index = 0

    while index < len(source):
        raw = source[index]
        stripped = raw.strip()
        indent = raw[: len(raw) - len(raw.lstrip())]

        opens_docstring = stripped.startswith('"""') and not (
            len(stripped) > 3 and stripped.endswith('"""')
        )
        if opens_docstring:
            out.append(raw)
            index += 1
            body = []
            while index < len(source) and source[index].strip() != '"""':
                body.append(source[index])
                index += 1
            out.extend(rewrap_docstring(body, indent, width))
            if index < len(source):
                out.append(source[index])
            index += 1
            continue

        is_comment_run = stripped.startswith("#") and not stripped.startswith("# --")
        if is_comment_run:
            block = []
            while index < len(source):
                current = source[index]
                current_indent = current[: len(current) - len(current.lstrip())]
                if not current.strip().startswith("#") or current.strip().startswith("# --"):
                    break
                if current_indent != indent:
                    break
                block.append(current.strip().lstrip("#").strip())
                index += 1
            out.extend(wrap_paragraph(" ".join(block), indent + "# ", width))
            continue

        out.append(raw)
        index += 1

    return out


JSDOC_TAG = "@"


def rewrap_block_comment(body: list, star_indent: str, width: int) -> list:
    """
    Reflow the prose in a `/* */` block, keeping the leading ` * ` on each line.

    A line opening with a JSDoc tag starts a run that is copied through, since `@param x the id`
    is a record rather than a sentence.
    """
    out: list = []
    paragraph: list = []
    prefix = star_indent + "* "

    def flush() -> None:
        if paragraph:
            out.extend(wrap_paragraph(" ".join(paragraph), prefix, width))
            paragraph.clear()

    for raw in body:
        text = raw.strip()
        if text.startswith("*"):
            text = text[1:].strip()
        if not text:
            flush()
            out.append((star_indent + "*").rstrip())
        elif text.startswith(JSDOC_TAG):
            flush()
            out.append(prefix + text)
        else:
            paragraph.append(text)
    flush()
    return out


def rewrap_typescript(source: list, width: int) -> list:
    out: list = []
    index = 0
    in_template = False

    while index < len(source):
        raw = source[index]
        stripped = raw.strip()
        indent = raw[: len(raw) - len(raw.lstrip())]

        # A line inside a template literal only looks like a comment, so leave it alone.
        if in_template or (stripped.count("`") % 2 and not stripped.startswith(("//", "*", "/*"))):
            in_template = in_template != bool(stripped.count("`") % 2)
            out.append(raw)
            index += 1
            continue

        opens_block = stripped.startswith("/*") and not stripped.endswith("*/")
        if opens_block:
            out.append(raw)
            index += 1
            body = []
            while index < len(source) and not source[index].strip().startswith("*/"):
                body.append(source[index])
                index += 1
            out.extend(rewrap_block_comment(body, indent + " ", width))
            if index < len(source):
                out.append(source[index])
            index += 1
            continue

        if stripped.startswith("//") and not stripped.startswith("///"):
            block = []
            while index < len(source):
                current = source[index]
                current_indent = current[: len(current) - len(current.lstrip())]
                text = current.strip()
                if not text.startswith("//") or text.startswith("///") or current_indent != indent:
                    break
                block.append(text.lstrip("/").strip())
                index += 1
            out.extend(wrap_paragraph(" ".join(block), indent + "// ", width))
            continue

        out.append(raw)
        index += 1

    return out


def changed_line_numbers(path: str):
    """
    Lines that differ from git HEAD, 1-based. None means "treat every line as changed",
    which covers a new file and anything outside a git checkout.
    """
    # git runs from the file's own directory, so it must be given the absolute path:
    # a caller's relative path would not resolve from there.
    absolute = os.path.abspath(path)
    directory = os.path.dirname(absolute) or "."
    try:
        diff = subprocess.run(
            ["git", "diff", "-U0", "--no-color", "--", absolute],
            capture_output=True, text=True, timeout=10, cwd=directory,
        )
        tracked = subprocess.run(
            ["git", "ls-files", "--error-unmatch", "--", absolute],
            capture_output=True, text=True, timeout=10, cwd=directory,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if tracked.returncode != 0 or diff.returncode != 0:
        return None

    changed = set()
    for start, count in re.findall(r"^@@ -\S+ \+(\d+)(?:,(\d+))? @@", diff.stdout, re.M):
        first = int(start)
        for offset in range(int(count) if count else 1):
            changed.add(first + offset)
    return changed


def rewrap_source(path: str, source: list, width: int, only_changed: bool) -> list:
    rewrap = rewrap_python if path.endswith(".py") else rewrap_typescript
    if not only_changed:
        return rewrap(source, width)

    changed = changed_line_numbers(path)
    if changed is None:
        return rewrap(source, width)
    if not changed:
        return source
    return rewrap_changed_blocks(rewrap, source, width, changed)


def rewrap_changed_blocks(rewrap, source: list, width: int, changed: set) -> list:
    """
    Rewrap one changed region at a time, so untouched comments keep the shape they already have.

    A region is a run of changed lines padded by a line either side, since a comment block often
    sits just above the code that moved. Regions are spliced bottom up, because rewrapping alters
    the line count and would shift the ones below it.
    """
    out = list(source)
    for start, end in reversed(changed_regions(changed, len(source))):
        out[start - 1 : end] = rewrap(out[start - 1 : end], width)
    return out


def changed_regions(changed: set, total: int) -> list:
    """Contiguous runs of changed lines, each padded by one line, as 1-based inclusive pairs."""
    regions = []
    for line in sorted(changed):
        padded = (max(1, line - 1), min(total, line + 1))
        if regions and padded[0] <= regions[-1][1] + 1:
            regions[-1] = (regions[-1][0], max(regions[-1][1], padded[1]))
        else:
            regions.append(padded)
    return regions


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path")
    parser.add_argument("--width", type=int, default=99)
    parser.add_argument("--check", action="store_true")
    parser.add_argument(
        "--all",
        action="store_true",
        help="Rewrap the whole file instead of only comments near changed lines.",
    )
    args = parser.parse_args()

    original = open(args.path).read()
    result = "\n".join(
        rewrap_source(args.path, original.split("\n"), args.width, only_changed=not args.all)
    )

    if result == original:
        print(f"{args.path}: unchanged")
        return
    if args.check:
        print(f"{args.path}: comments need rewrapping")
        sys.exit(1)
    open(args.path, "w").write(result)
    print(f"{args.path}: rewrapped")


if __name__ == "__main__":
    main()
