SELECT 
    *
FROM
    portfolioproject.layoffs_staging2;

-- Determining the date range to understand the timeframe of the dataset.
SELECT 
    MIN(`date`), MAX(`date`)
FROM
    layoffs_staging2;

-- Analyzing the distribution of companies across industries.

SELECT 
    Industry, COUNT(company) AS company_count
FROM
    layoffs_staging2
GROUP BY Industry
ORDER BY company_count DESC;

-- Tracking the count of companies by year to identify trends over time.

SELECT 
    YEAR(Date) AS year, COUNT(company) AS company_count
FROM
    layoffs_staging2
GROUP BY year
ORDER BY year;

-- Examining the distribution of companies by their headquarters location.

SELECT 
    Location_HQ, COUNT(company) AS company_count
FROM
    layoffs_staging2
GROUP BY Location_HQ
ORDER BY company_count DESC;

-- Analyzing the count of companies by country for geographic insights.

SELECT 
    Country, COUNT(company) AS company_count
FROM
    layoffs_staging2
GROUP BY Country
ORDER BY company_count DESC;

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
FROM
    layoffs_staging2;

-- Identifying companies that laid off 100% of their workforce.

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    Percentage = 100;

-- Ordering by funds raised to understand the scale of these companies.

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    Percentage = 100
ORDER BY Funds_Raised DESC;

-- Identifying the top 10 companies with the largest single-day layoffs.

SELECT 
    company, laid_off_count
FROM
    layoffs_staging2
ORDER BY 2 DESC
LIMIT 10;

-- Determining the top 10 companies with the highest total layoffs.

SELECT 
    company, SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- Analyzing location-wise total layoffs to identify hotspots.

SELECT 
    Location_HQ, SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY Location_HQ
ORDER BY 2 DESC
LIMIT 10;

-- Summarizing country-wise total layoffs to identify the most impacted countries.

SELECT 
    Country, SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY Country
ORDER BY 2 DESC;

-- Summarizing industry-wise total layoffs to identify the most impacted industries.

SELECT 
    Industry, SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY Industry
ORDER BY 2 DESC;

-- Analyzing stage-wise total layoffs to identify which business stages were most affected. 

SELECT 
    Stage, SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY Stage
ORDER BY 2 DESC;

-- Summarizing year-wise total layoffs to identify the most impacted years.

SELECT 
    YEAR(`date`), SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Calculating the rolling total of layoffs per month for trend analysis.

SELECT 
    SUBSTRING(`date`, 1, 7) AS `Months`, SUM(laid_off_count)
FROM
    layoffs_staging2
GROUP BY `Months`
ORDER BY `Months`;

with months_cte as
(
select substring(`date`,1,7) as `Months`, sum(laid_off_count) as total_layoffs
from layoffs_staging2
group by `Months`
order by `Months`
)
select `Months`, total_layoffs, 
sum(total_layoffs) over(order by `Months` asc) as rolling_total_layoffs
from months_cte;

-- Identifying the companies with the highest total layoffs per year. 

SELECT 
    company,
    YEAR(`date`) AS `year`,
    SUM(laid_off_count) AS total_layoffs
FROM
    layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY 3 DESC;

with company_year as 
(select company, year(`date`) as `year`, sum(laid_off_count) as total_layoffs 
from layoffs_staging2
GROUP BY company, year(`date`)
order by 2 desc
),
company_year_rank as
(
select company, `year`, total_layoffs, 
dense_rank() over(PARTITION BY `year` ORDER BY total_layoffs desc) as Ranking
from company_year
)
select company, `year`, total_layoffs, Ranking
from company_year_rank
where Ranking <=5;

-- Identifying the industries with the highest total layoffs per year.

SELECT 
    industry,
    YEAR(`date`) AS `year`,
    SUM(laid_off_count) AS total_layoffs
FROM
    layoffs_staging2
GROUP BY industry , YEAR(`date`)
ORDER BY 3 DESC;

with industry_year as 
(select industry, year(`date`) as `year`, sum(laid_off_count) as total_layoffs 
from layoffs_staging2
GROUP BY industry, year(`date`)
order by 2 desc
),
industry_year_rank as
(
select industry, `year`, total_layoffs, 
dense_rank() over(PARTITION BY `year` ORDER BY total_layoffs desc) as Ranking
from industry_year
)
select industry, `year`, total_layoffs, Ranking
from industry_year_rank
where Ranking <=5;

-- Identifying the countries with the highest total layoffs per year.

SELECT 
    country,
    YEAR(`date`) AS `year`,
    SUM(laid_off_count) AS total_layoffs
FROM
    layoffs_staging2
GROUP BY country , YEAR(`date`)
ORDER BY 3 DESC;

with country_year as 
(select country, year(`date`) as `year`, sum(laid_off_count) as total_layoffs 
from layoffs_staging2
GROUP BY country, year(`date`)
order by 2 desc
),
country_year_rank as
(
select country, `year`, total_layoffs, 
dense_rank() over(PARTITION BY `year` ORDER BY total_layoffs desc) as Ranking
from country_year
)
select country, `year`, total_layoffs, Ranking
from country_year_rank
where Ranking <=5;

-- The exploratory data analysis (EDA) on the cleaned data has been successfully executed. The results provide valuable insights into the dataset, helping to understand trends, distributions, and key metrics.
















