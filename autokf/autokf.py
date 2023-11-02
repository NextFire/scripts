#!/usr/bin/env python3
import re
from pathlib import Path

import click
from pysubs2 import SSAFile

K_MATCH = re.compile(r"{\\k([123456]\d{2,}|[789]\d+)}([\w]+)([^{]*)( |$)")


def auto_kf(subs: SSAFile):
    for sub in subs.events:
        for match in K_MATCH.finditer(sub.text):
            k_duration = int(match.group(1))
            content = match.group(2)
            extra = match.group(3)
            space = match.group(4)

            new_k_duration = k_duration // 8
            kf_duration = k_duration - new_k_duration
            space_k = r"{\k0}" if space == " " else ""

            repl = rf"{{\k{new_k_duration}}}{content}{{\kf{kf_duration}}}~{extra}{space_k}{space}"

            sub.text = sub.text.replace(match.group(0), repl)
    return subs


@click.command()
@click.argument("subs_file", type=click.Path(exists=True, path_type=Path))
def main(subs_file: Path):
    subs = SSAFile.load(subs_file)
    subs = auto_kf(subs)
    subs.save(subs_file)


if __name__ == "__main__":
    main()
