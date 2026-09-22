# CMS Hospital Performance Analytics

This project is an end-to-end data analytics project based on CMS hospital performance data.

I used Python to clean and explore the data, SQL Server to store and analyze it, and Power BI to build an interactive dashboard.

The main purpose of the project was to look at hospital performance across different healthcare measures, compare records with national benchmarks, and analyze patient-related metrics.

---

## Project Overview

The dataset contains hospital performance information such as:

- Hospital and facility details
- Healthcare measures
- Performance scores
- Number of patients
- Number of patients returned
- Comparison with national benchmarks
- Reporting dates

The project follows this workflow:

**Raw Data → Python → SQL Server → SQL Analysis → Power BI**

---

## Dataset

The original dataset contains:

- **67,368 records**
- **20 columns**

Some of the important columns are:

- `Facility ID`
- `Facility Name`
- `State`
- `Measure ID`
- `Measure Name`
- `Score`
- `Denominator`
- `Number of Patients`
- `Number of Patients Returned`
- `Compared to National`
- `Start Date`
- `End Date`

---

## Tools Used

- Python
- Pandas
- Jupyter Notebook
- SQL Server
- SQL
- Power BI
- DAX

---

## 1. Data Cleaning and EDA

I first worked with the dataset in Python using Pandas.

The main cleaning steps were:

- Converted numeric columns to numeric data types.
- Converted the start and end dates to datetime.
- Checked for duplicate records.
- Checked missing values.
- Standardized ZIP codes.
- Handled missing footnotes.
- Created numeric versions of columns such as Score and Denominator.
- Explored patient and performance-related data.

The dataset contains values such as `Not Available` and `Not Applicable`.

I did not replace these values with zero because an unavailable value does not mean that the actual value was zero. These values were treated as missing when performing numerical analysis.

I also performed some initial EDA to understand:

- Hospital distribution by state
- Available scores by healthcare measure
- Patient return data
- Missing values

---

## 2. SQL Server Database

After cleaning the data, I loaded it into SQL Server.

Database:

`CMS_Healthcare`

I created a star schema with one fact table and three dimension tables.

### Dimension Tables

#### Dim_Facility

Contains hospital information such as:

- Facility ID
- Facility Name
- Address
- City
- State
- ZIP Code

#### Dim_Measure

Contains:

- Measure ID
- Measure Name

#### Dim_Date

Contains:

- Start Date
- End Date

### Fact Table

#### Fact_Performance

Contains the hospital performance records and the related measures.

The dimension tables are connected to the fact table using primary key and foreign key relationships.

---

## 3. SQL Analysis

I used SQL Server to perform analysis on the cleaned data.

Some of the questions I worked on were:

- How many hospitals are present in each state?
- Which healthcare measures have the most available scores?
- What is the average score for each measure?
- How do records compare with national benchmarks?
- Which states have more records classified as worse than the national rate?
- What is the patient return rate based on the available patient data?
- Which healthcare measures have greater score variation?
- Which hospitals appear among the top 3 scores for different measures?

I also used SQL window functions such as `RANK()` for the hospital ranking analysis.

---

## 4. Power BI Dashboard

The final dashboard was created in Power BI using the star schema.

### Page 1 — Hospital Performance Overview

This page gives an overall view of the dataset.

It includes:

- Total Hospitals
- Total Performance Records
- Average Score
- Patient Return Rate
- Hospitals by State
- National Performance Comparison
- Available Scores by Healthcare Measure
- Worse Than National by State

### Page 2 — Patient Outcomes & Readmissions

This page focuses on patient-related metrics.

It includes:

- Total Patients
- Patients Returned
- Patient Return Rate
- Average Score
- Patient Return Rate by State
- Average Score by Healthcare Measure
- Average Patients Returned by Healthcare Measure
- Score Variation by Healthcare Measure

### Page 3 — Performance Benchmarks & Rankings

This page focuses on national benchmark comparisons and hospital rankings.

It includes:

- Better Than National
- Worse Than National
- No Different Than National
- Available Scores
- Hospital Distribution by State
- Highest-Scoring Hospitals by Measure
- Top 3 Measure Appearances by Hospital

---

## 5. Dashboard Preview

### Hospital Performance Overview

![Hospital Performance Overview]<img width="962" height="680" alt="Screenshot 2026-09-22 224146" src="https://github.com/user-attachments/assets/52141261-662c-4082-abdb-a87908492752" />


### Patient Outcomes & Readmissions

![Patient Outcomes & Readmissions](<img width="783" height="665" alt="Screenshot 2026-09-22 224234" src="https://github.com/user-attachments/assets/d16d9285-6c8a-4e87-90db-2056a22a149f" />


### Performance Benchmarks & Rankings

![Performance Benchmarks & Rankings](<img width="945" height="748" alt="Screenshot 2026-09-22 224533" src="https://github.com/user-attachments/assets/29727a18-358e-40d5-97e5-16571287b76e" />


---

## 6. DAX Measures

I created several measures in Power BI for the dashboard.

Some of them are:

- Total Hospitals
- Total Performance Records
- Average Score
- Total Patients
- Total Patients Returned
- Patient Return Rate
- Better Than National
- Worse Than National
- No Different Than National
- Available Score

---

## Some Results

A few values from the final analysis/dashboard were:

- **67,368** performance records
- Around **5K** hospitals
- **333** records classified as Better Than the National Rate
- **418** records classified as Worse Than the National Rate
- **23,775** records classified as No Different Than the National Rate
- **29.38%** patient return rate based on the available patient records used in the analysis

The benchmark numbers above represent **performance records**, not unique hospitals.

---

## Project Structure

```text
CMS-Hospital-Performance-Analytics/
│
├── README.md
│
├── Python/
│   └── CMS_Data_Cleaning_EDA.ipynb
│
├── SQL/
│   └── CMS_Analysis.sql
│
├── Data/
│   └── CMS_Cleaned.xlsx
│
├── PowerBI/
│   └── CMS.pbix
│
└── Screenshots/
    ├── page1.png
    ├── page2.png
    └── page3.png
