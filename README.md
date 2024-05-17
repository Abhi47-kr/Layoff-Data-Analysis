# DATA_CLEANING & EDA_in_MySQL

## TABLE OF CONTENTS

- [PROJECT OVERVIEW](#project-overview)
- [DATA SOURCES](#data-sources)
- [TOOL](#tool)
- [THE CLEANING PROCESS](#the-cleaning-process)
- [EXPLORATORY DATA ANALYSIS](#exploratory-data-analysis)
- [CONCLUSION](#conclusion)

## PROJECT OVERVIEW

This project focuses on cleaning raw data within MySQL using various MySQL functions. The objective is to transform the data into a structured format suitable for Exploratory Data Analysis (EDA). Data cleaning and EDA are crucial for uncovering insights and making informed decisions based on reliable data.

## DATA SOURCES

The dataset used in the project is the *[Layoffs Dataset 2024](https://www.kaggle.com/datasets/theakhilb/layoffs-data-2022)* sourced from Kaggle. The dataset encompasses diverse industry specific information on layoffs comprising of 3577 rows and 12 columns. 

## TOOL

- MySQL

## THE CLEANING PROCESS

- Creating a Staging Table:

```sql
-- Creating a staging table to safeguard against data loss during processing.
create table layoffs_staging
like layoffs_data;

insert into layoffs_staging
select *
from layoffs_data;
```

- Eliminating Unnecessary Columns:

```sql
-- Eliminating unnecessary columns to streamline data.
alter table layoffs_staging
drop column `source`,
drop column date_added,
drop column list_of_employees_laid_off;
```

- Identifying and Examining Potential Duplicate Records:

```sql
-- Identifying and examining potential duplicate records for validation.
select *, ROW_NUMBER() 
over(partition by company, location_hq, industry, laid_off_count, percentage, `date`, funds_raised, stage, country) as row_num
from layoffs_staging;
```

- Removing Duplicate Entries:

```sql
-- Removing duplicate entries to ensure data integrity.
DELETE from layoffs_staging2
where row_num>1;
```

- Handling Null or Empty Values:

```sql
-- Handling null or empty values by converting blank entries to null values.
UPDATE layoffs_staging2
SET laid_off_count = NULLIF(laid_off_count, ''),
    percentage = NULLIF(percentage, ''),
    funds_raised = NULLIF(funds_raised, '');
```

- Standardizing Data:

```sql
-- Standardizing data for consistency and clarity.
-- 1. Removing leading and trailing spaces from the company names.
UPDATE layoffs_staging2 
SET company = TRIM(company);
```

- Adjusting Data Types and Formats:

```sql
-- 2. Adjusting data types and formats for Laid_Off_Count, Percentage, Funds_Raised, and Date columns.
alter table layoffs_staging2
modify column Laid_Off_Count int,
modify column Percentage int,
modify column `Date` date,
modify  column Funds_Raised int;
```

- Removing Irrelevant Rows with Null Values:

```sql
-- Removing irrelevant rows with null values.
delete
from layoffs_staging2
where Laid_Off_Count is null and percentage is null;
```

## EXPLORATORY DATA ANALYSIS

Here are key SQL queries used in the EDA process:-

- Industry Distribution:

```sql
-- Analyzing the distribution of companies across industries.
SELECT Industry, COUNT(company) AS company_count
FROM layoffs_staging2
GROUP BY Industry
ORDER BY company_count DESC;
```

- Yearly Trends:

```sql
-- Tracking the count of companies by year to identify trends over time.
SELECT YEAR(Date) AS year, COUNT(company) AS company_count
FROM layoffs_staging2
GROUP BY year
ORDER BY year;
```

- Summary Statistics:

```sql
-- Generating summary statistics for numerical columns like laid off count, percentage, and funds raised.
SELECT 
    COUNT(*) AS total_rows,
    AVG(Laid_off_count) AS avg_laid_off,
    MAX(Laid_off_count) AS max_laid_off,
    MIN(Laid_off_count) AS min_laid_off,
    AVG(Percentage) AS avg_percentage,
    MAX(Percentage) AS max_percentage,
    MIN(Percentage) AS min_percentage,
    AVG(Funds_raised) AS avg_funds_raised,
    MAX(Funds_raised) AS max_funds_raised,
    MIN(Funds_raised) AS min_funds_raised
FROM layoffs_staging2;
```

- Top Companies by Layoffs:

```sql
-- Identifying the top 10 companies with the largest single-day layoffs.
SELECT company, laid_off_count
FROM layoffs_staging2
ORDER BY 2 DESC
LIMIT 10;
```

- Total Layoffs by Location:

```sql
-- Analyzing location-wise total layoffs to identify hotspots.
SELECT Location_HQ, SUM(laid_off_count) AS total_layoffs
FROM layoffs_staging2
GROUP BY Location_HQ
ORDER BY total_layoffs DESC
LIMIT 10;
```

- Rolling Total of Layoffs:

```sql
-- Calculating the rolling total of layoffs per month for trend analysis.
WITH months_cte AS (
    SELECT SUBSTRING(`date`, 1, 7) AS `Months`, SUM(laid_off_count) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY `Months`
    ORDER BY `Months`
)
SELECT `Months`, total_layoffs, 
    SUM(total_layoffs) OVER(ORDER BY `Months` ASC) AS rolling_total_layoffs
FROM months_cte;
```

- Industries with Highest Total Layoffs per Year:

```sql
-- Identifying the industries with the highest total layoffs per year.
SELECT 
    industry,
    YEAR(`date`) AS `year`,
    SUM(laid_off_count) AS total_layoffs
FROM
    layoffs_staging2
GROUP BY industry, YEAR(`date`)
ORDER BY total_layoffs DESC;

WITH industry_year AS (
    SELECT industry, YEAR(`date`) AS `year`, SUM(laid_off_count) AS total_layoffs 
    FROM layoffs_staging2
    GROUP BY industry, YEAR(`date`)
    ORDER BY `year` DESC
),
industry_year_rank AS (
    SELECT industry, `year`, total_layoffs, 
    DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoffs DESC) AS Ranking
    FROM industry_year
)
SELECT industry, `year`, total_layoffs, Ranking
FROM industry_year_rank
WHERE Ranking <= 5;
```

These are just some of the SQL queries used in the analysis; the full set of queries can be found in the attached SQL query file.

## CONCLUSION

By thoroughly cleaning the data, we ensured its reliability for an in-depth EDA process. This analysis provided valuable insights into layoffs across different dimensions, including industry, geography, and time.
  
