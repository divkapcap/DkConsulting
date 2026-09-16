import sqlite3
from pathlib import Path

import pandas as pd
import matplotlib.pyplot as plt


# ============================================================
# SETUP
# ============================================================

# Find the project folder
PROJECT_FOLDER = Path(__file__).resolve().parent.parent

# Database location
DATABASE_PATH = PROJECT_FOLDER / "DKCONSULTING.db"

# Folder where graphs will be saved
CHART_FOLDER = Path(__file__).resolve().parent / "charts"
CHART_FOLDER.mkdir(parents=True, exist_ok=True)


# Connect to SQLite database
conn = sqlite3.connect(DATABASE_PATH)

print("=" * 60)
print("PROFITABILITY ANALYSIS")
print("=" * 60)
print(f"Database: {DATABASE_PATH}")
print()


# ============================================================
# 1. ORDERS BY REGION
# ============================================================

print("1. Orders by Region")

query = """
SELECT
    c.region,
    COUNT(o.order_id) AS order_count
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY order_count DESC
"""

df = pd.read_sql_query(query, conn)

print(df)
print()

plt.figure(figsize=(8, 5))

plt.bar(
    df["region"],
    df["order_count"]
)

plt.xlabel("Region")
plt.ylabel("Number of Orders")
plt.title("Orders by Region")

plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "orders_by_region.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()


# ============================================================
# 2. MONTHLY PROFIT
# ============================================================

print("2. Monthly Profit")

# Item profit and shipping profit are calculated separately.
# This prevents shipping revenue/cost from being counted
# multiple times when an order has multiple items.

query = """
WITH item_profit AS (
    SELECT
        o.order_id,
        o.order_date,

        SUM(
            oi.quantity * oi.unit_price
            - COALESCE(oi.discount_amount, 0)
            - oi.quantity * p.standard_cost
        ) AS item_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        o.order_id,
        o.order_date
),

shipping_profit AS (
    SELECT
        o.order_id,

        COALESCE(o.shipping_revenue, 0)
        - COALESCE(f.shipping_cost, 0) AS shipping_profit

    FROM orders o

    LEFT JOIN fulfillment f
        ON o.order_id = f.order_id
)

SELECT
    strftime('%Y-%m', item_profit.order_date) AS month,

    SUM(
        item_profit.item_profit
        + COALESCE(shipping_profit.shipping_profit, 0)
    ) AS profit

FROM item_profit

LEFT JOIN shipping_profit
    ON item_profit.order_id = shipping_profit.order_id

GROUP BY month
ORDER BY month
"""

df = pd.read_sql_query(query, conn)

print(df)
print()

plt.figure(figsize=(12, 6))

plt.plot(
    df["month"],
    df["profit"],
    marker="o"
)

plt.axhline(
    0,
    linewidth=1
)

plt.xlabel("Month")
plt.ylabel("Profit ($)")
plt.title("Monthly Profit")

plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "monthly_profit.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()


# Find lowest-profit month
lowest_month = df.loc[df["profit"].idxmin()]

print(
    f"Lowest profit month: "
    f"{lowest_month['month']} "
    f"(${lowest_month['profit']:,.2f})"
)

print()


# ============================================================
# 3. WHICH PRODUCTS LOSE MONEY?
# ============================================================

print("3. Products Operating at a Loss")

query = """
SELECT
    p.product_id,
    p.product_name,

    SUM(
        oi.quantity * oi.unit_price
        - COALESCE(oi.discount_amount, 0)
        - oi.quantity * p.standard_cost
    ) AS profit

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY
    p.product_id,
    p.product_name

HAVING profit < 0

ORDER BY profit ASC
"""

df = pd.read_sql_query(query, conn)

print(df)
print()

plt.figure(figsize=(11, 7))

plt.barh(
    df["product_name"],
    df["profit"]
)

plt.axvline(
    0,
    linewidth=1
)

plt.xlabel("Profit ($)")
plt.ylabel("Product")
plt.title("Products Operating at a Loss")

plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "unprofitable_products.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()


print(f"Number of unprofitable products: {len(df)}")
print()


# ============================================================
# 4. WHICH CUSTOMERS ARE UNPROFITABLE?
# ============================================================

print("4. Unprofitable Customers")

query = """
WITH item_profit AS (
    SELECT
        o.order_id,
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
            - COALESCE(oi.discount_amount, 0)
            - oi.quantity * p.standard_cost
        ) AS item_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        o.order_id,
        o.customer_id
),

shipping_profit AS (
    SELECT
        o.order_id,

        COALESCE(o.shipping_revenue, 0)
        - COALESCE(f.shipping_cost, 0) AS shipping_profit

    FROM orders o

    LEFT JOIN fulfillment f
        ON o.order_id = f.order_id
),

customer_profit AS (
    SELECT
        item_profit.customer_id,

        SUM(
            item_profit.item_profit
            + COALESCE(shipping_profit.shipping_profit, 0)
        ) AS profit

    FROM item_profit

    LEFT JOIN shipping_profit
        ON item_profit.order_id = shipping_profit.order_id

    GROUP BY item_profit.customer_id
)

SELECT
    customer_id,
    profit

FROM customer_profit

WHERE profit < 0

ORDER BY profit ASC
"""

df = pd.read_sql_query(query, conn)

print(f"Number of unprofitable customers: {len(df)}")
print()

# Show the 20 customers with the largest losses
plot_df = df.head(20)

print("Top 20 customers with the largest losses:")
print(plot_df)
print()

plt.figure(figsize=(12, 7))

plt.barh(
    plot_df["customer_id"],
    plot_df["profit"]
)

plt.axvline(
    0,
    linewidth=1
)

plt.xlabel("Profit ($)")
plt.ylabel("Customer")
plt.title("Top 20 Unprofitable Customers")

plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "unprofitable_customers.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()


# ============================================================
# 5. WHICH REGIONS LOSE MONEY?
# ============================================================

print("5. Profit by Region")

query = """
WITH item_profit AS (
    SELECT
        o.order_id,
        o.customer_id,

        SUM(
            oi.quantity * oi.unit_price
            - COALESCE(oi.discount_amount, 0)
            - oi.quantity * p.standard_cost
        ) AS item_profit

    FROM orders o

    JOIN order_items oi
        ON o.order_id = oi.order_id

    JOIN products p
        ON oi.product_id = p.product_id

    GROUP BY
        o.order_id,
        o.customer_id
),

shipping_profit AS (
    SELECT
        o.order_id,

        COALESCE(o.shipping_revenue, 0)
        - COALESCE(f.shipping_cost, 0) AS shipping_profit

    FROM orders o

    LEFT JOIN fulfillment f
        ON o.order_id = f.order_id
)

SELECT
    c.region,

    SUM(
        item_profit.item_profit
        + COALESCE(shipping_profit.shipping_profit, 0)
    ) AS profit

FROM item_profit

JOIN customers c
    ON item_profit.customer_id = c.customer_id

LEFT JOIN shipping_profit
    ON item_profit.order_id = shipping_profit.order_id

GROUP BY c.region

ORDER BY profit
"""

df = pd.read_sql_query(query, conn)

print(df)
print()

plt.figure(figsize=(9, 6))

plt.bar(
    df["region"],
    df["profit"]
)

plt.axhline(
    0,
    linewidth=1
)

plt.xlabel("Region")
plt.ylabel("Profit ($)")
plt.title("Profit by Region")

plt.xticks(rotation=45)
plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "profit_by_region.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()


# Display regions that are losing money
loss_regions = df[df["profit"] < 0]

print("Regions with negative profit:")
print(loss_regions)
print()


# ============================================================
# 6. ARE HIGH DISCOUNTS ASSOCIATED WITH LOW PROFIT?
# ============================================================

print("6. Discount Amount vs. Profit")

query = """
SELECT
    COALESCE(oi.discount_amount, 0) AS discount,
    (
    oi.quantity * oi.unit_price
    - COALESCE(oi.discount_amount, 0)
    - oi.quantity * p.standard_cost
    ) AS profit
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
    """

df = pd.read_sql_query(query, conn)

print(df.head())
print()

plt.figure(figsize=(11, 6))
plt.scatter(df["discount"], df["profit"], alpha=0.5)

plt.axhline(0, color="red", linewidth=1)

plt.xlabel("Discount Amount ($)")
plt.ylabel("Profit ($)")
plt.title("Discount Amount vs. Profit")

plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "discount_vs_profit.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()

correlation = df["discount"].corr(df["profit"])
print(f"Correlation between discount and profit: {correlation:.3f}")

print()

# ============================================================
# 7. REVENUE VS COST VS PROFIT
# ============================================================

PROJECT_FOLDER = Path(__file__).resolve().parent.parent

# Database location
DATABASE_PATH = PROJECT_FOLDER / "DKCONSULTING.db"

# Folder where graphs will be saved
CHART_FOLDER = Path(__file__).resolve().parent / "charts"
CHART_FOLDER.mkdir(parents=True, exist_ok=True)


# Connect to SQLite database
conn = sqlite3.connect(DATABASE_PATH)

print("=" * 60)
print("PROFITABILITY ANALYSIS")
print("=" * 60)
print(f"Database: {DATABASE_PATH}")
print()


# ============================================================
# 7. REVENUE VS COST VS PROFIT
# ============================================================

print("7. Revenue vs Cost vs Profit")

query = """
SELECT
    p.category,

    SUM(oi.quantity * oi.unit_price) AS revenue,
    SUM(oi.quantity * p.standard_cost) AS cost,
    SUM(oi.quantity * oi.unit_price - COALESCE(oi.discount_amount, 0) - oi.quantity * p.standard_cost) AS profit
FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

GROUP BY p.category

ORDER BY profit
"""

df = pd.read_sql_query(query, conn)

print(df.head())
print()

plt.figure(figsize=(11, 6))

x = range(len(df))

plt.bar(
    [i - 0.25 for i in x],
    df["revenue"],
    width=0.25,
    label="Revenue",
)

plt.bar(
    [i - 0.25 for i in x],
    df["revenue"],
    width=0.25,
    label="Revenue"
)

plt.bar(
    x,
    df["cost"],
    width=0.25,
    label="Cost",
)

plt.bar(
    [i + 0.25 for i in x],
    df["profit"],
    width=0.25,
    label="Profit",
)

plt.xlabel("Product Category")
plt.ylabel("Amount")
plt.title("Revenue, Cost, and Profit by Product Category")
plt.legend()

plt.xticks(x, df["category"], rotation=45)

plt.legend()

plt.tight_layout()

plt.savefig(
    CHART_FOLDER / "revenue_cost_profit.png",
    dpi=300,
    bbox_inches="tight"
)

plt.show()
plt.close()
