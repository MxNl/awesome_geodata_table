"""Print every dataset link (download, documentation, DOI) once per line.

Used by .github/workflows/link-check.yaml: lychee checks the resulting list
instead of the raw CSV, where it would glue neighbouring fields into one URL.

Usage: python3 tests/extract_links.py [metadata/datasets.csv] > links.txt
"""
import csv
import sys

path = sys.argv[1] if len(sys.argv) > 1 else "metadata/datasets.csv"
links = []
with open(path, encoding="utf-8", newline="") as f:
    for row in csv.DictReader(f):
        for field in ("download_url", "doc_url"):
            if row.get(field):
                links.append(row[field].strip())
        if row.get("doi"):
            links.append("https://doi.org/" + row["doi"].strip())

for link in dict.fromkeys(links):  # unique, in file order
    print(link)
