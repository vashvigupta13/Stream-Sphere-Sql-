# StreamSphere OTT Platform: Content & User Engagement Analysis

MBA End-Term Project, SQL and Data Management (PMDE30605), IILM University, Greater Noida.

A PostgreSQL database for a hypothetical OTT streaming platform. It links users, content, subscriptions, viewing history, ratings and payments, cleans the data and answers content, engagement and revenue questions with SQL.

## Group members

| Name | Roll No. |
|------|----------|
| Shruti Saraswat | 25SOM2039002519 |
| Khushi Sharma | 25SOM2039004775 |
| Vashvi Gupta | 25SOM2039003914 |
| Harshit Shukla | 25SOM2039004278 |
| Priyal Patel | 25SOM2039002933 |

Faculty: Dr. Lalit Kumar

## Repository contents

```
README.md                                   project summary and run instructions
data/                                       six CSV files and data_dictionary.csv
sql/streamsphere_project.sql                full SQL script (sections 1 to 7)
report/StreamSphere_Project_Report.pdf      project report with ER diagram, pgAdmin screenshots and insights
```

## Tools

PostgreSQL 18 and pgAdmin 4.

## How to run

1. In pgAdmin, create a database (we used `End term Project`) and open a Query Tool on it.
2. Run **Section 1** of `sql/streamsphere_project.sql` to create the six tables.
3. Import the CSV files from `data/` (right-click a table > Import/Export Data, Format csv, Header on) in this order:
   users, content, subscriptions, viewing_history, ratings, payments.
4. Run the rest of the script from **Section 2** onwards. The script is safe to run more than once.

## What the script covers

| Section | Content |
|---------|---------|
| 1 | Table creation: primary keys, foreign keys, NOT NULL and CHECK constraints |
| 2 | Verify that all six tables exist |
| 3 | Data quality checks (3a), cleaning of blank cities and genre labels (3b), verification (3c) |
| 4 | Ten analysis queries: joins, aggregation, CASE, subqueries, CTE, RANK() window function, DATE_TRUNC |
| 5 | Revenue at risk and integrity audit: payment status, payment method failures, cancellation rate, cross-table checks |
| 6 | Constraint tests: invalid inserts rejected by CHECK, FOREIGN KEY and PRIMARY KEY |
| 7 | Transactions: COMMIT, ROLLBACK and SAVEPOINT on a subscription renewal |

## Key findings

- Movies are 17 of 40 titles but 57.9% of watch minutes; series have higher completion (73.6% vs 64.0%).
- The most-watched title, *Midnight Run*, has the lowest average rating (1.91).
- Premium and Standard earn 77% of revenue, but Standard has a 27.6% cancellation rate.
- ₹7,980 (18.2% of billed value) is failed or pending.

The dataset is hypothetical and was created for this course project.

