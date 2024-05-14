# DATA_CLEANING & EDA_in_MySQL

## TABLE OF CONTENTS

- [PROJECT OVERVIEW](#project-overview)
- [DATA SOURCES](#data-sources)
- [TOOL](#tool)
- [THE CLEANING PROCESS](#the-cleaning-process)
- [EXPLORATORY DATA ANALYSIS](#exploratory-data-analysis)
- [CONCLUSION](#conclusion)

## PROJECT OVERVIEW

This project focuses on cleaning raw data within MySQL using different MySQL functions. The objective is to transform the data into a structured format suitable for Exploratory Data Analysis.

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



## CONCLUSION

Through thorough cleaning steps, the data is now made reliable for detailed analysis, ensuring accurate insights.
  
