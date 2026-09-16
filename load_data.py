import csv
import sqlite3
from pathlib import Path


PROJECT_FOLDER = Path(__file__).resolve().parent
DATA_FOLDER = PROJECT_FOLDER / "data"
DATABASE_FILE = PROJECT_FOLDER / "DKCONSULTING.db"


TABLE_FILES = {
    "customers": "customers.csv",
    "orders": "orders.csv",
    "order_items": "order_items.csv",
    "products": "products.csv",
    "fulfillment": "fulfillment.csv",
    "returns": "returns.csv",
}


def clean_column_name(column_name):
    return (
        column_name.strip()
        .replace(" ", "_")
        .replace("-", "_")
        .lower()
    )


def quote_identifier(identifier):
    escaped_identifier = identifier.replace('"', '""')
    return f'"{escaped_identifier}"'


def load_csv_to_sqlite(connection, table_name, csv_path):
    print(f"Loading {csv_path.name} into {table_name}...")

    with csv_path.open(
        mode="r",
        encoding="utf-8-sig",
        newline=""
    ) as csv_file:

        reader = csv.reader(csv_file)
        header = next(reader)

        columns = [
            clean_column_name(column)
            for column in header
        ]

        quoted_table = quote_identifier(table_name)

        connection.execute(
            f"DROP TABLE IF EXISTS {quoted_table}"
        )

        column_definitions = ", ".join(
            f"{quote_identifier(column)} TEXT"
            for column in columns
        )

        connection.execute(
            f"""
            CREATE TABLE {quoted_table} (
                {column_definitions}
            )
            """
        )

        placeholders = ", ".join(
            "?" for _ in columns
        )

        insert_statement = (
            f"INSERT INTO {quoted_table} "
            f"VALUES ({placeholders})"
        )

        batch = []
        row_count = 0

        for row in reader:
            batch.append(row)

            if len(batch) >= 5000:
                connection.executemany(
                    insert_statement,
                    batch
                )
                row_count += len(batch)
                batch = []

        if batch:
            connection.executemany(
                insert_statement,
                batch
            )
            row_count += len(batch)

        print(
            f"Loaded {row_count:,} rows "
            f"into {table_name}."
        )


def main():
    missing_files = []

    for filename in TABLE_FILES.values():
        csv_path = DATA_FOLDER / filename

        if not csv_path.exists():
            missing_files.append(str(csv_path))

    if missing_files:
        print("The following files were not found:")

        for file_path in missing_files:
            print(file_path)

        raise FileNotFoundError(
            "One or more required CSV files are missing."
        )

    connection = sqlite3.connect(DATABASE_FILE)

    try:
        connection.execute("PRAGMA foreign_keys = OFF")

        for table_name, filename in TABLE_FILES.items():
            csv_path = DATA_FOLDER / filename

            load_csv_to_sqlite(
                connection,
                table_name,
                csv_path
            )

        connection.commit()

        print()
        print("Database created successfully:")
        print(DATABASE_FILE)
        print()

        results = connection.execute(
            """
            SELECT
                name
            FROM sqlite_master
            WHERE type = 'table'
            ORDER BY name
            """
        ).fetchall()

        print("Tables created:")

        for result in results:
            table_name = result[0]

            row_count = connection.execute(
                f"""
                SELECT COUNT(*)
                FROM {quote_identifier(table_name)}
                """
            ).fetchone()[0]

            print(
                f"  {table_name}: "
                f"{row_count:,} rows"
            )

    finally:
        connection.close()


if __name__ == "__main__":
    main()