import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path

# Styling
sns.set_style("whitegrid")
plt.rcParams["figure.figsize"] = (10, 6)


# Folder paths
base_path = Path(".")
data_path = base_path / "output"

# Load files
category = pd.read_csv(data_path / "category_profitability.csv")
monthly = pd.read_csv(data_path / "monthly_profitability.csv")
returns = pd.read_csv(data_path / "returns_by_category_reason.csv")
promotion = pd.read_csv(data_path / "promotion_profitability.csv")
channel = pd.read_csv(data_path / "channel_profitability.csv")
warehouse = pd.read_csv(data_path / "warehouse_performance.csv")

# Create charts directory
charts_dir = base_path / "charts"
charts_dir.mkdir(exist_ok=True)

print("Current folder:", Path.cwd())
print("Data folder:", data_path.resolve())
print("Charts folder:", charts_dir.resolve())

# 1. Category Profitability
plt.figure()
sns.barplot(
    data=category,
    x=category.columns[0],
    y=category.columns[-1],
    palette="Blues_r"
)
plt.title("Profitability by Category")
plt.xticks(rotation=30)
plt.tight_layout()
plt.savefig(charts_dir / "category_profitability.png")
plt.close()

# 2. Monthly Profitability Trend
plt.figure()
plt.plot(
    monthly.iloc[:, 0],
    monthly.iloc[:, -1],
    marker="o",
    linewidth=3
)
plt.title("Monthly Profitability Trend")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(charts_dir / "monthly_profitability.png")
plt.close()

# 3. Return Reasons
plt.figure()
return_summary = returns.groupby(
    returns.columns[-2]
)[returns.columns[-1]].sum().sort_values(ascending=False)

return_summary.plot(kind="bar", color="crimson")
plt.title("Return Value by Reason")
plt.tight_layout()
plt.savefig(charts_dir / "return_reasons.png")
plt.close()

# 4. Sales Channel Performance
plt.figure()
sns.barplot(
    data=channel,
    x=channel.columns[0],
    y=channel.columns[-1],
    palette="viridis"
)
plt.title("Channel Profitability")
plt.tight_layout()
plt.savefig(charts_dir / "channel_profitability.png")
plt.close()

# 5. Promotion Impact
plt.figure()
sns.barplot(
    data=promotion,
    x=promotion.columns[0],
    y=promotion.columns[-1],
    palette="magma"
)
plt.title("Promotion Profitability")
plt.xticks(rotation=30)
plt.tight_layout()
plt.savefig(charts_dir / "promotion_profitability.png")
plt.close()

# 6. Warehouse Performance
plt.figure()
sns.barplot(
    data=warehouse,
    x=warehouse.columns[0],
    y=warehouse.columns[-1],
    palette="Set2"
)
plt.title("Warehouse Performance")
plt.tight_layout()
plt.savefig(charts_dir / "warehouse_performance.png")
plt.close()

print("Charts created successfully in 'charts' folder.")