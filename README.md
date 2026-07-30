# CDNow Customer Survival Analysis

A end-to-end survival analysis project on the CDNow dataset, built on a **medallion architecture in SQL Server** and analysed using Python's `lifelines` library. The project models customer churn through time-to-event analysis - identifying when customers stop purchasing and what drives retention.

---

## Project Structure

```
CDNOW/
│
├── bronze/
│   ├── ddlBronze.sql           # Bronze schema + table definition
│   └── loadBronze.sql          # Bronze load procedure (BULK INSERT)
│
├── silver/
│   ├── ddlSilver.sql           # Silver schema + table definition
│   └── loadSilver.sql          # Silver load procedure (duration, inactivity, churn flag)
│
├── gold/
│   ├── ddlGold.sql             # Gold schema + table definition
│   └── loadGold.sql            # Gold load procedure (customer-level aggregation)
│
├── cdnow.csv/
│   └── cdnow.csv               # Raw transaction data
│
├── tests/
│   ├── gold.sql                # Gold layer validation queries
│   ├── SQLQuery1.sql           # Ad-hoc test queries
│   └── SQLQuery2.sql           # Ad-hoc test queries
│
├── survival_analysis.ipynb     # KM curve, Cox PH, C-index, predictions
└── README.md
```

---

## Architecture - Medallion Pipeline

```
Bronze (raw)  →  Silver (features)  →  Gold (customer-level)
```

| Layer | Description |
|-------|-------------|
| **Bronze** | Raw CDNow transactions ingested via `BULK INSERT` into SQL Server |
| **Silver** | Per-transaction features: `duration` (months from first to last purchase), `inactivity` (months since last purchase to dataset end), `event` flag (1 if inactivity ≥ 6 months) |
| **Gold** | One row per customer: `duration`, `event`, `total_spent`, `total_orders` - the final modelling table |

---

## Dataset

The **CDNow dataset** is a classic e-commerce transaction log containing ~69,659 records across ~23,570 unique customers, spanning 1997–1998. It is widely used in BTYD (Buy Till You Die) and customer lifetime value research.

**Columns:** `customer_id`, `date`, `quantity`, `price`

---

## Churn Definition

> A customer is defined as **churned** if they have been inactive for **6 or more months** before the end of the observation window.

This threshold is encoded in the Silver layer:

```sql
CASE WHEN inactivity >= 6 THEN 1 ELSE 0 END AS event
```

---

## Analysis

### 1. Kaplan-Meier Survival Curve

- The survival curve **starts at ~0.46**, not 1.0 - indicating a large proportion of customers are one-time buyers who churn immediately (duration = 0)
- The curve never crosses 50%, meaning the **median survival time is undefined**
- By month 10, only ~22% of customers remain active - these are the loyal, repeat buyers
- `total_orders` mode = 1, confirming the dataset is heavily skewed toward one-time purchasers

### 2. Cox Proportional Hazards Model

| Covariate | Hazard Ratio | Interpretation |
|-----------|-------------|----------------|
| `total_orders` | **0.385** | Each additional order reduces churn hazard by ~61.5% |
| `total_spent` | **1.000014** | Negligible independent effect on churn |

**Key insight:** Repeat purchase behaviour is the dominant driver of retention. Spend amount alone does not predict churn - a customer who spends heavily in a single order is just as likely to churn as one who spends little.

### 3. Model Evaluation

| Metric | Value |
|--------|-------|
| **C-index** | **0.926** |

The C-index of 0.926 indicates strong concordance - the model correctly ranks which customers churn sooner in 92.6% of valid pairs. However, this high score is largely driven by `total_orders`, which almost perfectly separates churners (1 order) from retained customers (2+ orders) by construction in this dataset. This is an expected characteristic of the CDNow data rather than an indication of model overfitting.

### 4. Conditional Survival Prediction

Survival probabilities were predicted for non-churned customers (`event = 0`), conditional on having survived to their current duration. Median predicted survival returned `inf` for all - consistent with the KM curve never crossing 50%.

---

## Key Findings

- **~54% of customers churn immediately** (duration = 0, single purchase)
- **Only 22% remain active beyond 10 months** - these are the high-value loyal segment
- **Order frequency, not spend, drives retention** - customers with 2+ orders are 61.5% less likely to churn at any given time
- The dataset exhibits classic BTYD behaviour: a large inactive majority and a small loyal core

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| SQL Server (Express) | Data warehouse - bronze/silver/gold pipeline |
| Python 3 | Analysis |
| `lifelines` | Kaplan-Meier, Cox PH, survival prediction |
| `pandas` | Data manipulation |
| `seaborn` / `matplotlib` | Visualisation |
| `pyodbc` | SQL Server connection from Python |

---

## How to Run

### 1. Set up the database

Run SQL scripts in order:

```
bronze/ddlBronze.sql  →  bronze/loadBronze.sql
silver/ddlSilver.sql  →  silver/loadSilver.sql
gold/ddlGold.sql      →  gold/loadGold.sql
```

Update the file path in `loadBronze.sql` to point to your local `cdnow.csv`.

### 2. Run the notebook

```bash
pip install lifelines pyodbc pandas seaborn matplotlib
jupyter notebook notebooks/survival_analysis.ipynb
```

Update the connection string in Cell 1 to match your SQL Server instance.

---

## Limitations

- Churn threshold (6 months inactivity) is a business assumption - results would differ with a different threshold
- Only two covariates available in the gold layer; richer features (e.g. recency, product category) could improve model discrimination
- C-index is inflated by the near-perfect predictive power of `total_orders` in this specific dataset
