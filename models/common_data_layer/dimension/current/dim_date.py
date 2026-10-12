import pandas as pd
import holidays
from datetime import datetime, timedelta


def model(dbt, session):
    dbt.config(
        materialized="incremental",
        incremental_strategy="append",
        packages=["pandas", "holidays"],
    )

    # Skip rebuild on incremental runs — table already has data, grants stay intact
    if dbt.is_incremental:
        return session.sql(f"SELECT * FROM {dbt.this} WHERE 1=0")

    # Date range via dbt vars — override at build time:
    #   dbt run --select dim_date --vars '{"dim_date_start": "2015-01-01", "dim_date_end": "2035-12-31"}'
    # These are wired through the YAML config meta (cdm_models.yml)
    start_date = dbt.config.get("meta", {}).get("dim_date_start") or dbt.config.get("dim_date_start") or "2010-01-01"
    end_date = dbt.config.get("meta", {}).get("dim_date_end") or dbt.config.get("dim_date_end") or "2030-12-31"

    sd = datetime.strptime(start_date, "%Y-%m-%d")
    ed = datetime.strptime(end_date, "%Y-%m-%d")
    dates = pd.date_range(start=sd, end=ed)

    states = ["NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT"]

    # Pre-compute holidays per state for all years in range
    state_holidays = {}
    for state in states:
        combined = {}
        for yr in range(sd.year, ed.year + 1):
            combined.update(holidays.Australia(state=state, years=yr))
        state_holidays[state] = combined

    rows = []
    working_day_seq = {state: 0 for state in states}

    for d in dates:
        dt = d.to_pydatetime()
        date_key = int(dt.strftime("%Y%m%d"))
        year = dt.year
        month = dt.month
        day = dt.day
        month_name = dt.strftime("%B")
        day_name = dt.strftime("%A")
        day_of_year = dt.timetuple().tm_yday
        quarter = (month - 1) // 3 + 1
        is_weekend = day_name in ("Saturday", "Sunday")

        # Australian fiscal year: July to June
        if month >= 7:
            fiscal_year = year + 1
            fiscal_month = month - 6
        else:
            fiscal_year = year
            fiscal_month = month + 6

        fiscal_quarter = (fiscal_month - 1) // 3 + 1

        fy_start = datetime(fiscal_year - 1, 7, 1)
        fy_end = datetime(fiscal_year, 6, 30)

        # Fiscal week calculation based on Monday-start weeks
        monday_of_week = dt - timedelta(days=dt.weekday())
        monday_of_fy_start = fy_start - timedelta(days=fy_start.weekday())
        fiscal_week = (monday_of_week - monday_of_fy_start).days // 7 + 1

        fw_start = monday_of_week
        fw_end = fw_start + timedelta(days=6)

        row = {
            "DATE_KEY": date_key,
            "DATE": dt.date(),
            "YEAR": year,
            "MONTH": month,
            "DAY": day,
            "MONTH_NAME": month_name,
            "DAY_NAME": day_name,
            "DAY_OF_YEAR": day_of_year,
            "QUARTER": quarter,
            "IS_WEEKEND": is_weekend,
            "FISCAL_YEAR": fiscal_year,
            "FISCAL_MONTH": fiscal_month,
            "FISCAL_QUARTER": fiscal_quarter,
            "FISCAL_YEAR_START_DATE": int(fy_start.strftime("%Y%m%d")),
            "FISCAL_YEAR_END_DATE": int(fy_end.strftime("%Y%m%d")),
            "FISCAL_WEEK": fiscal_week,
            "FISCAL_WEEK_START_DATE": int(fw_start.strftime("%Y%m%d")),
            "FISCAL_WEEK_END_DATE": int(fw_end.strftime("%Y%m%d")),
        }

        # Per-state holiday and working day calculations
        for state in states:
            hol = state_holidays[state]
            is_holiday = dt.date() in hol
            holiday_val = "Yes" if is_holiday else "No"
            is_working = not is_weekend and not is_holiday

            row[f"HOLIDAY_IN_{state}"] = holiday_val

            if is_working:
                # Working day of week (Mon-start)
                week_start = dt - timedelta(days=dt.weekday())
                wd_of_week = 0
                check = week_start
                while check <= dt:
                    if check.weekday() < 5 and check.date() not in hol:
                        wd_of_week += 1
                    check += timedelta(days=1)

                # Working day of month
                first_of_month = dt.replace(day=1)
                wd_of_month = 0
                check = first_of_month
                while check <= dt:
                    if check.weekday() < 5 and check.date() not in hol:
                        wd_of_month += 1
                    check += timedelta(days=1)

                row[f"WORKING_DAY_OF_WEEK_{state}"] = wd_of_week
                row[f"WORKING_DAY_OF_MONTH_{state}"] = wd_of_month
            else:
                row[f"WORKING_DAY_OF_WEEK_{state}"] = 0
                row[f"WORKING_DAY_OF_MONTH_{state}"] = 0

            if is_working:
                working_day_seq[state] += 1
                row[f"WORKING_DAY_SEQ_{state}"] = working_day_seq[state]
            else:
                row[f"WORKING_DAY_SEQ_{state}"] = 0

        rows.append(row)

    df = pd.DataFrame(rows)

    # Ensure session has database and schema set for write_pandas
    session.use_database(dbt.this.database)
    session.use_schema(dbt.this.schema)

    return session.create_dataframe(df)
