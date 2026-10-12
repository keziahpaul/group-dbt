#!/usr/bin/env python3
"""Apply AI-corrected governance tags from Anomaly CSV to dbt model YAML files.

Reads the TAG-Anomalies-Extraction-AI CSV, filters to CONFIRMED rows,
resolves each row to a dbt model YAML file and column, and applies
secure_field=<AI_CORRECTION> tags using line-based text editing to preserve
original formatting, comments, and indentation.
"""

import argparse
import csv
import logging
import os
import re
import sys

logger = logging.getLogger(__name__)

# Mapping from (CATALOG, SCHEMA) to dbt layer directory path.
CATALOG_SCHEMA_MAP = {
    ("PRD_GROUP_COMMON_DATA_LAYER", "CDM"): "models/common_data_layer/",
    ("PRD_GROUP_COMMON_DATA_LAYER", "ODS"): "models/on_day_settlement/",
    ("PRD_GROUP_EXT_DATASERVICES", "ANZ_DATASERVICES"): "models/external_data_services/bespoke_reporting/anz/",
    ("PRD_GROUP_EXT_DATASERVICES", "CBA_DATASERVICES"): "models/external_data_services/bespoke_reporting/cba/",
    ("PRD_GROUP_EXT_DATASERVICES", "KAPICHE_DATASERVICES"): "models/external_data_services/kapiche/",
    ("PRD_GROUP_EXT_DATASERVICES", "NAB_DATASERVICES"): "models/external_data_services/bespoke_reporting/nab/",
    ("PRD_GROUP_EXT_DATASERVICES", "WESTPAC_DATASERVICES"): "models/external_data_services/bespoke_reporting/westpac/",
    ("PRD_GROUP_INT_DATASERVICES", "SALESFORCE_DATASERVICES"): "models/internal_data_services/salesforce/",
    ("PRD_GROUP_SELFSERVICE_ANALYTICS", "EXCHANGE"): "models/internal_data_services/billing_and_invoice/",
    ("PRD_GROUP_STAGE", "FMS"): "models/staging/FMS/",
    ("PRD_GROUP_STAGE", "SALESFORCE"): "models/staging/salesforce/",
    ("PRD_GROUP_STAGE", "SENDFX"): "models/staging/sendfx/",
}


def parse_args(argv=None):
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Apply AI-corrected tags from Anomaly CSV to dbt model YAML files."
    )
    parser.add_argument(
        "csv_path",
        help="Path to the TAG-Anomalies-Extraction-AI CSV file.",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose (INFO-level) logging.",
    )
    return parser.parse_args(argv)


def configure_logging(verbose=False):
    """Configure logging to stdout with appropriate level."""
    level = logging.INFO if verbose else logging.WARNING
    logging.basicConfig(
        level=level,
        format="%(levelname)s: %(message)s",
        stream=sys.stdout,
    )


def read_csv(csv_path):
    """Read all rows from the Anomaly CSV file."""
    with open(csv_path, newline="", encoding="utf-8-sig", errors="replace") as f:
        reader = csv.DictReader(f)
        return list(reader)


def filter_confirmed_rows(rows):
    """Filter CSV rows to only CONFIRMED rows with valid AI_CORRECTION."""
    results = []
    for row in rows:
        confirmed = row.get("CONFIRMED", "")
        if confirmed != "CONFIRMED":
            continue
        ai_correction = row.get("AI_CORRECTION", "")
        if not ai_correction or not ai_correction.strip():
            continue
        results.append({
            "catalog": row.get("CATALOG", ""),
            "schema": row.get("SCHEMA", ""),
            "table_name": row.get("TABLE_NAME", ""),
            "column_name": row.get("COLUMN_NAME", ""),
            "ai_correction": ai_correction.strip().upper(),
        })
    return results


def resolve_yaml_paths(catalog, schema):
    """Resolve a (CATALOG, SCHEMA) pair to the dbt layer directory path."""
    key = (catalog.strip().upper(), schema.strip().upper())
    path = CATALOG_SCHEMA_MAP.get(key)
    if path is None:
        logger.warning(
            "Unmapped CATALOG/SCHEMA pair: (%s, %s) — skipping", key[0], key[1]
        )
    return path


def find_yaml_files(yaml_path):
    """Find all .yml/.yaml files in directory recursively."""
    if not os.path.isdir(yaml_path):
        return []
    result = []
    for root, _dirs, files in os.walk(yaml_path):
        for fname in sorted(files):
            if fname.endswith((".yml", ".yaml")):
                result.append(os.path.join(root, fname))
    return result


def find_column_line(lines, model_name, column_name):
    """Find the line index of a column within a model in a YAML file.

    Uses text-based parsing to find the column definition line.
    Returns (column_line_idx, column_indent) or (None, None) if not found.
    """
    model_name_lower = model_name.lower()
    column_name_lower = column_name.lower()

    # Find the model by looking for "- name: <model_name>" pattern
    model_line = None
    model_indent = None
    for i, line in enumerate(lines):
        match = re.match(r'^(\s*)- name:\s*(.+)', line)
        if match:
            indent = len(match.group(1))
            name_val = match.group(2).strip().strip('"').strip("'")
            # Models are at indent level 2 (under "models:" list)
            if indent <= 4 and name_val.lower() == model_name_lower:
                model_line = i
                model_indent = indent
                break

    if model_line is None:
        return None, None

    # Find "columns:" section within this model
    columns_line = None
    for i in range(model_line + 1, len(lines)):
        line = lines[i]
        stripped = line.lstrip()
        current_indent = len(line) - len(stripped)

        # If we hit another model at same or lower indent, stop
        if current_indent <= model_indent and stripped.startswith("- name:") and i != model_line:
            break

        if stripped.startswith("columns:"):
            columns_line = i
            break

    if columns_line is None:
        return None, None

    # Find the specific column within the columns list
    col_list_indent = len(lines[columns_line]) - len(lines[columns_line].lstrip())
    for i in range(columns_line + 1, len(lines)):
        line = lines[i]
        if not line.strip():
            continue
        stripped = line.lstrip()
        current_indent = len(line) - len(stripped)

        # If indent is <= columns indent, we've exited the columns section
        if current_indent <= col_list_indent and not stripped.startswith("-"):
            break

        match = re.match(r'^(\s*)- name:\s*(.+)', line)
        if match:
            col_indent = len(match.group(1))
            name_val = match.group(2).strip().strip('"').strip("'")
            if name_val.lower() == column_name_lower:
                return i, col_indent

    return None, None


def find_next_column_or_section_end(lines, col_line, col_indent):
    """Find where the current column definition ends.

    Returns the line index of the next sibling column or the end of the columns section.
    """
    for i in range(col_line + 1, len(lines)):
        line = lines[i]
        if not line.strip():
            continue
        stripped = line.lstrip()
        current_indent = len(line) - len(stripped)

        # Another column at same indent level
        if current_indent == col_indent and stripped.startswith("- name:"):
            return i

        # Back to parent indent (exited columns section)
        if current_indent <= col_indent and not stripped.startswith("-"):
            # Check if it's a blank line before another section
            return i

    return len(lines)


def get_column_config_tags_info(lines, col_line, col_end, col_indent):
    """Analyze the column's existing config and tags structure.

    Returns a dict with:
        - has_config: bool
        - config_line: int or None (line index of "config:")
        - has_tags: bool
        - tags_line: int or None (line index of "tags:")
        - existing_secure_field_line: int or None
        - existing_secure_field_value: str or None
        - tags_indent: int (indent level of tags entries)
        - config_indent: int (indent level of config key)
    """
    info = {
        "has_config": False,
        "config_line": None,
        "has_tags": False,
        "tags_line": None,
        "existing_secure_field_line": None,
        "existing_secure_field_value": None,
        "tags_indent": 0,
        "config_indent": 0,
    }

    # Column properties are at col_indent + 2
    # e.g. "      - name: x" has col_indent=6, properties like "        config:" are at indent 8
    prop_indent = col_indent + 2

    for i in range(col_line + 1, col_end):
        line = lines[i]
        if not line.strip():
            continue
        stripped = line.lstrip()
        current_indent = len(line) - len(stripped)

        # Look for "config:" at property level (same as data_type, description, etc.)
        if current_indent == prop_indent and stripped.rstrip() == "config:":
            info["has_config"] = True
            info["config_line"] = i
            info["config_indent"] = current_indent
            continue

        # Look for "tags:" inside config (one level deeper)
        if info["has_config"] and current_indent == prop_indent + 2 and stripped.rstrip() == "tags:":
            info["has_tags"] = True
            info["tags_line"] = i
            info["tags_indent"] = current_indent + 2  # tag entries are 2 more
            continue

        # Look for existing secure_field= tag inside tags list
        if info["has_tags"] and stripped.startswith("- secure_field="):
            info["existing_secure_field_line"] = i
            info["existing_secure_field_value"] = stripped[2:].strip()  # Remove "- "
            continue

    return info


def apply_tag_to_file_lines(lines, col_line, col_indent, ai_correction):
    """Apply the secure_field=<AI_CORRECTION> tag to a column using line editing.

    Returns (modified_lines, changed) tuple.
    """
    tag_value = f"secure_field={ai_correction}"
    col_end = find_next_column_or_section_end(lines, col_line, col_indent)
    info = get_column_config_tags_info(lines, col_line, col_end, col_indent)

    # Property indent for this column's attributes
    prop_indent = col_indent + 2

    if info["has_tags"] and info["existing_secure_field_line"] is not None:
        # Case: existing secure_field tag — check if it matches
        if info["existing_secure_field_value"] == tag_value:
            return lines, False  # Already correct, no change
        # Replace the existing tag line
        line_idx = info["existing_secure_field_line"]
        indent = len(lines[line_idx]) - len(lines[line_idx].lstrip())
        lines[line_idx] = " " * indent + f"- {tag_value}\n"
        return lines, True

    if info["has_tags"]:
        # Case: config.tags exists but no secure_field=* — append after tags:
        insert_idx = info["tags_line"] + 1
        # Skip past existing tag entries to append at end of tags list
        while insert_idx < col_end:
            line = lines[insert_idx]
            if not line.strip():
                insert_idx += 1
                continue
            stripped = line.lstrip()
            current_indent = len(line) - len(stripped)
            if current_indent >= info["tags_indent"] and stripped.startswith("-"):
                insert_idx += 1
            else:
                break
        new_line = " " * info["tags_indent"] + f"- {tag_value}\n"
        lines.insert(insert_idx, new_line)
        return lines, True

    if info["has_config"]:
        # Case: config exists but no tags key — insert tags as first key in config
        config_content_indent = info["config_indent"] + 2
        insert_idx = info["config_line"] + 1
        tags_line = " " * config_content_indent + "tags:\n"
        entry_line = " " * (config_content_indent + 2) + f"- {tag_value}\n"
        lines.insert(insert_idx, tags_line)
        lines.insert(insert_idx + 1, entry_line)
        return lines, True

    # Case: no config block at all — create config.tags block
    # Insert after the column's existing properties (before next column or section end)
    # Find where to insert (after existing properties of this column)
    insert_idx = col_line + 1
    while insert_idx < col_end:
        line = lines[insert_idx]
        if not line.strip():
            insert_idx += 1
            continue
        stripped = line.lstrip()
        current_indent = len(line) - len(stripped)
        # If we're still within this column's properties
        if current_indent > col_indent:
            insert_idx += 1
        else:
            break

    config_indent = prop_indent
    config_line = " " * config_indent + "config:\n"
    tags_line = " " * (config_indent + 2) + "tags:\n"
    entry_line = " " * (config_indent + 4) + f"- {tag_value}\n"
    lines.insert(insert_idx, config_line)
    lines.insert(insert_idx + 1, tags_line)
    lines.insert(insert_idx + 2, entry_line)
    return lines, True


def find_model_in_files(yaml_files, table_name):
    """Find which YAML file contains a model matching table_name.

    Returns (file_path, model_name_as_in_file) or (None, None).
    """
    target = table_name.strip().lower()
    for file_path in yaml_files:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
        except Exception:
            continue

        # Quick check before full parsing
        if target not in content.lower():
            continue

        lines = content.split("\n")
        for line in lines:
            match = re.match(r'^\s*- name:\s*(.+)', line)
            if match:
                name_val = match.group(1).strip().strip('"').strip("'")
                if name_val.lower() == target:
                    return file_path, name_val

    return None, None


def process_corrections(csv_path):
    """Main orchestration: read CSV, resolve paths, apply tags via text editing."""
    rows = read_csv(csv_path)
    logger.info("Total rows read: %d", len(rows))

    corrections = filter_confirmed_rows(rows)
    logger.info("Confirmed corrections to apply: %d", len(corrections))

    if not corrections:
        return (0, 0, [])

    # Group corrections by (catalog, schema)
    grouped = {}
    for rec in corrections:
        key = (rec["catalog"], rec["schema"])
        grouped.setdefault(key, []).append(rec)

    applied = 0
    skipped = 0
    warnings = []
    # Track file contents: file_path -> list of lines
    file_lines_cache = {}
    modified_files = set()

    for (catalog, schema), records in grouped.items():
        layer_path = resolve_yaml_paths(catalog, schema)
        if layer_path is None:
            msg = f"Unmapped CATALOG/SCHEMA: ({catalog}, {schema}) — {len(records)} row(s) skipped"
            warnings.append(msg)
            skipped += len(records)
            continue

        yaml_files = find_yaml_files(layer_path)
        if not yaml_files:
            msg = f"No YAML files found in: {layer_path} — {len(records)} row(s) skipped"
            warnings.append(msg)
            skipped += len(records)
            continue

        # Cache model -> file mapping
        model_file_cache = {}

        for rec in records:
            table_name = rec["table_name"]
            column_name = rec["column_name"]
            ai_correction = rec["ai_correction"]

            # Find the file containing this model
            cache_key = table_name.lower()
            if cache_key not in model_file_cache:
                model_file_cache[cache_key] = find_model_in_files(yaml_files, table_name)

            file_path, model_name = model_file_cache[cache_key]
            if file_path is None:
                msg = (
                    f"Model not found: TABLE_NAME='{table_name}' "
                    f"in path '{layer_path}' (CATALOG={catalog}, SCHEMA={schema})"
                )
                warnings.append(msg)
                skipped += 1
                continue

            # Load file lines (cached)
            if file_path not in file_lines_cache:
                with open(file_path, "r", encoding="utf-8") as f:
                    file_lines_cache[file_path] = f.readlines()

            lines = file_lines_cache[file_path]

            # Find the column line
            col_line, col_indent = find_column_line(lines, model_name, column_name)
            if col_line is None:
                msg = (
                    f"Column not found: COLUMN_NAME='{column_name}' "
                    f"in model '{model_name}' ({file_path})"
                )
                warnings.append(msg)
                skipped += 1
                continue

            # Apply the tag
            lines, changed = apply_tag_to_file_lines(lines, col_line, col_indent, ai_correction)
            file_lines_cache[file_path] = lines
            if changed:
                applied += 1
                modified_files.add(file_path)
            else:
                skipped += 1

    # Write modified files
    for file_path in modified_files:
        logger.info("Writing modified YAML: %s", file_path)
        with open(file_path, "w", encoding="utf-8") as f:
            f.writelines(file_lines_cache[file_path])

    return (applied, skipped, warnings)


def main(argv=None):
    """Main entry point."""
    args = parse_args(argv)
    configure_logging(args.verbose)

    logger.info("Processing CSV: %s", args.csv_path)
    applied, skipped, warnings = process_corrections(args.csv_path)

    print(f"\n--- Summary ---")
    print(f"Applied:  {applied}")
    print(f"Skipped:  {skipped}")
    print(f"Warnings: {len(warnings)}")

    if warnings:
        print(f"\n--- Warnings ---")
        for w in warnings:
            print(f"  • {w}")


if __name__ == "__main__":
    main()
