# 🛒🏥 Consumer Behavior & Patient Outcomes — Data Mining with R

> A group project for the BSc in Applied Data Science Communication  
> General Sir John Kotelawala Defense University | Data Mining — Year 2, Semester 1

---

## 📌 Project Overview

This project applies two core data mining techniques to real-world datasets across two different domains:

| Technique | Domain | Goal |
|---|---|---|
| **Association Rule Mining (ARM)** | E-Commerce / Online Retail | Discover product co-purchase patterns |
| **Logistic Regression** | Healthcare / Diabetic Patients | Predict 30-day hospital readmission |

Both analyses are delivered as **interactive Shiny web applications** built in R.

---

## 📁 Repository Structure

```
├── lastarm.R               # Shiny app — Association Rule Mining (Online Retail)
├── lastlranalysis.R        # Shiny app — Logistic Regression (Diabetic Readmission)
├── diabetic_data.csv       # Dataset for logistic regression (place in working directory)
└── README.md
```

---

## 🛒 Part 1 — Association Rule Mining (ARM)

### Dataset
**Online Retail Dataset** — transactional data from a UK-based online retailer (Excel `.xlsx` format, uploaded via the app).

### How It Works
- Upload the Online Retail `.xlsx` file through the Shiny interface
- The app cleans the data: removes missing values, cancellations (`InvoiceNo` starting with `C`), and converts it to transaction basket format
- The **Apriori algorithm** mines association rules based on user-defined **support** and **confidence** thresholds
- Top 10 rules ranked by **lift** are displayed in a table and visualized

### Visualizations
- 📊 **Scatterplot** — Support vs. Confidence, colored by Lift
- 🔲 **Grouped Matrix Plot** — Antecedent/consequent item groupings
- 🕸️ **Graph Plot** — Network view of item relationships

### Key Metrics
| Metric | Description |
|---|---|
| **Support** | How frequently the itemset appears in transactions |
| **Confidence** | Probability that RHS is bought when LHS is bought |
| **Lift** | Strength of the rule vs. random co-occurrence; Lift > 1 = positive association |

### Running the App
```r
# Install required packages if needed
install.packages(c("shiny", "readxl", "arules", "arulesViz", "tidyverse"))

# Run the app
shiny::runApp("lastarm.R")
```

---

## 🏥 Part 2 — Logistic Regression (Diabetic Readmission)

### Dataset
**Diabetic Patient Dataset** — 10 years of clinical data including demographics, diagnoses, medications, and admission details (`diabetic_data.csv`).

### How It Works
- Place `diabetic_data.csv` in your working directory (or upload via the app)
- The app preprocesses the data: removes irrelevant/high-missing columns, encodes categorical variables, creates binary target (`readmitted within 30 days = 1`)
- A **Logistic Regression** model is trained on 70% of the data and evaluated on the remaining 30%
- Results include model summary, confusion matrix, and ROC curve

### Visualizations
- 🟩 **Confusion Matrix Heatmap** — True/False Positives and Negatives
- 📈 **ROC Curve** — Model discrimination ability across thresholds

### Key Concepts
| Concept | Description |
|---|---|
| **Binary Target** | 1 = readmitted within 30 days, 0 = not readmitted |
| **Odds Ratio > 1** | Predictor increases readmission likelihood |
| **AUC** | Area Under ROC Curve; closer to 1.0 = stronger model |

### Running the App
```r
# Install required packages if needed
install.packages(c("shiny", "tidyverse", "caret", "e1071", "pROC", "ggplot2"))

# Run the app
shiny::runApp("lastlranalysis.R")
```

---

## 👥 Team

| Student Number | Name |
|---|---|
| D/ADC/24/0047 | Muhammed Nasir |
| D/ADC/24/0036 | Rajintha Lakshani |
| D/ADC/24/0008 | Chamali Abeysekara |
| D/ADC/24/0007 | Hussein Ziyard |

---

## 🛠️ Tech Stack

- **Language:** R
- **Framework:** Shiny
- **Key Packages:** `arules`, `arulesViz`, `caret`, `pROC`, `ggplot2`, `tidyverse`

---

## 📄 License

This project was developed for academic purposes at General Sir John Kotelawala Defense University.
