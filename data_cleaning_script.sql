SELECT 
    *
FROM
    layoffs_data;

-- Creating a staging table to safeguard against data loss during processing.

CREATE TABLE layoffs_staging LIKE layoffs_data;

insert layoffs_staging
select *
from layoffs_data;

SELECT 
    *
FROM
    layoffs_staging;

-- Eliminating unnecessary columns to streamline data.

alter table layoffs_staging
drop column `source`,
drop column date_added,
drop column list_of_employees_laid_off;

SELECT 
    *
FROM
    layoffs_staging;

-- Identifying and examining potential duplicate records for validation.

select *, ROW_NUMBER() 
over(partition by company, location_hq, industry, laid_off_count, percentage, `date`, funds_raised, stage, country) as row_num
from layoffs_staging;

with staging_cte as
(
select *, ROW_NUMBER() 
over(partition by company, location_hq, industry, laid_off_count, percentage, `date`, funds_raised, stage, country) as row_num
from layoffs_staging
)
select * from staging_cte
where row_num>1;

-- Verifying and cross-checking identified duplicates for accuracy.

SELECT 
    *
FROM
    layoffs_staging
WHERE
    company = 'Beyond Meat'
        OR company = 'Cazoo';

-- Removing duplicate entries to ensure data integrity.

CREATE TABLE `layoffs_staging2` (
    `Company` TEXT,
    `Location_HQ` TEXT,
    `Industry` TEXT,
    `Laid_Off_Count` TEXT,
    `Percentage` TEXT,
    `Date` TEXT,
    `Funds_Raised` TEXT,
    `Stage` TEXT,
    `Country` TEXT,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

insert into layoffs_staging2
select *, ROW_NUMBER() 
over(partition by company, location_hq, industry, laid_off_count, percentage, `date`, funds_raised, stage, country) as row_num
from layoffs_staging;

DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company = 'Beyond Meat'
        OR company = 'Cazoo';

-- Handling null or empty values by converting blank entries to null values.

UPDATE layoffs_staging2 
SET 
    laid_off_count = NULLIF(laid_off_count, ''),
    percentage = NULLIF(percentage, ''),
    funds_raised = NULLIF(funds_raised, '');

-- Standardizing data for consistency and clarity.

-- (i) Removing leading and trailing spaces from the company names.

SELECT 
    *
FROM
    layoffs_staging2;
SELECT DISTINCT
    (company)
FROM
    layoffs_staging2;

SELECT 
    company, TRIM(company)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

-- (ii) Adjusting formats for Laid_Off_Count, Percentage and Funds_Raised columns.

SELECT 
    laid_off_count,
    TRUNCATE(laid_off_count, 1),
    funds_raised,
    TRUNCATE(funds_raised, 1)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    laid_off_count = TRUNCATE(laid_off_count, 1),
    funds_raised = TRUNCATE(funds_raised, 1);

SELECT 
    Percentage, TRUNCATE(FORMAT(Percentage * 100, 2), 2)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    Percentage = TRUNCATE(FORMAT(Percentage * 100, 2), 2);

-- (iii) Extracting date portion and removing unnecessary time information from the "Date" column.

SELECT 
    `Date`, SUBSTRING(`Date`, 1, 10)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    `Date` = SUBSTRING(`Date`, 1, 10);

SELECT 
    *
FROM
    layoffs_staging2;

-- (iv) Adjusting data types for consistency and accuracy.

alter table layoffs_staging2
modify column Laid_Off_Count int,
modify column Percentage int,
modify column `Date` date,
modify  column Funds_Raised int;

-- Removing redundant row_num column.

alter table layoffs_staging2
drop column row_num;

-- Removing irrelevant rows with null values.

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    Laid_Off_Count IS NULL
        AND percentage IS NULL;

DELETE FROM layoffs_staging2 
WHERE
    Laid_Off_Count IS NULL
    AND percentage IS NULL;

SELECT 
    *
FROM
    layoffs_staging2;

-- The SQL script for data cleaning in MySQL has been successfully executed. The data has been cleansed, standardized, and prepared for further analysis.
    
    





 






