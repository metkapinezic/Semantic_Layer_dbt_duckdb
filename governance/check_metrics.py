
### The script enforces non-negotables semantic layer rules: 
  ## 1. Every metric must have a description.
  ## 2. Every metric must have an owner (meta.owner).
  ##3. No duplicate metric names across YAML files.

## Run: python governance/check_metrics.py
##Exit code 0 = pass, 1 = violations found 

## runs as github action step


import sys  # controls the exit code
import glob # finds files matching a pettern instead of hardcoding filenames
import yaml # parses yml text into py dicts and lists
from pathlib import Path # for building file paths

MODELS_DIR = Path(__file__).parent.parent / "models" / "mart_semantic" # defining the model path


def load_metrics():
    # Read every metric block across all YAML files, tagged with source file. #
    metrics = []
    for filepath in glob.glob(str(MODELS_DIR / "*.yml")): # for every takes every file with .yml
        with open(filepath) as f: # opens the file and guarantees it gets closed automatically afterward
            content = yaml.safe_load(f) # reads the file and turns it into a Python dict # safe_load only builds plain data structures — dicts, lists, strings, numbers.
        if not content or "metrics" not in content: # if there is no content or metrics in the file skip
            continue                 # jumps to the next file                   
        for metric in content["metrics"]:               # a list of dictionaries 
            metric["_source_file"] = Path(filepath).name
            metrics.append(metric)
    return metrics  # after all files are processed, hand back the full flat list every metric from every file, each one knowing where it came from


def check_missing_field(metrics, field_path, label):  # checker for missing field
    #field_path: e.g. 'description' or ('meta', 'owner')#
    violations = []
    for m in metrics:
        value = m
        for key in field_path if isinstance(field_path, tuple) else (field_path,):
            value = value.get(key, {}) if isinstance(value, dict) else None
        if not value:
            violations.append(f"  - '{m['name']}' ({m['_source_file']}) is missing {label}")
    return violations


def check_duplicate_names(metrics):  # For each metric: if its name is already a key in seen,that's a duplicate, so record a violation naming both files.
    seen = {}
    violations = []
    for m in metrics:
        name = m["name"]
        if name in seen:
            violations.append(
                f"  - '{name}' defined in both {seen[name]} and {m['_source_file']}"
            )
        else:
            seen[name] = m["_source_file"]
    return violations


def main():
    metrics = load_metrics()
    if not metrics:
        print("No metrics found — check MODELS_DIR path.")
        sys.exit(1)

    print(f"Checking {len(metrics)} metrics across {MODELS_DIR}...\n")

    all_violations = [] # A running list to collect every problem found across all three checks.

    missing_desc = check_missing_field(metrics, "description", "a description")
    if missing_desc:
        print("Missing description:")
        print("\n".join(missing_desc))
        all_violations += missing_desc

    missing_owner = check_missing_field(metrics, ("meta", "owner"), "an owner (meta.owner)")
    if missing_owner:
        print("Missing owner:")
        print("\n".join(missing_owner))
        all_violations += missing_owner

    dupes = check_duplicate_names(metrics)
    if dupes:
        print("Duplicate metric names:")
        print("\n".join(dupes))
        all_violations += dupes

    if all_violations:
        print(f"\n{len(all_violations)} violation(s) found. Failing build.")
        sys.exit(1)
    else:
        print("All metrics pass governance checks.")
        sys.exit(0)


if __name__ == "__main__":
    main()