from pathlib import Path
import re

root = Path(r"d:\\Spring_26\\mobile\\supermarket\\docs\\sequences")
files = sorted(root.glob("3-*.puml"))

standard = [
    "skinparam shadowing false\n",
    "skinparam responseMessageBelowArrow true\n",
    "skinparam sequenceMessageAlign center\n",
    "skinparam maxMessageSize 180\n",
    "skinparam sequenceParticipant underline false\n",
    "skinparam stereotypePosition top\n",
]

for p in files:
    t = p.read_text(encoding="utf-8")
    if not t.lstrip().startswith("@startuml"):
        continue

    lines = t.splitlines(keepends=True)

    title_idx = None
    for i, line in enumerate(lines):
        if re.match(r"^title\s+.*$", line.strip()):
            title_idx = i
            break

    if title_idx is None or title_idx == 0:
        continue

    if not lines[0].strip().startswith("@startuml"):
        continue

    new_lines = [lines[0]]
    new_lines.extend(standard)
    new_lines.extend(lines[title_idx:])
    nt = "".join(new_lines)

    # remove include line if still present
    nt = re.sub(r"^!include\\s+_seq-style\\.puml\\s*$\\n?", "", nt, flags=re.MULTILINE)

    if nt != t:
        p.write_text(nt, encoding="utf-8")
        print("updated", p.name)

print("done", len(files), "checked")

