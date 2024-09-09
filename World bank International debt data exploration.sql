
--THE WORLD BANK'S INTERNATIONAL DEBT DATA EXPLORATION PROJECT BY COLLINS AKAGHA

------------------------------------------------------------------------------------------

--Looking at the overall dataset
Select *
From [Portfolio Projects]..international_debt

--Looking at the number of distinct countries with debt
Select count(distinct(country_name)) Distinct_Country_Count
from [Portfolio Projects]..international_debt


--Looking at the total amount of debt owed by all the countries
Select round(sum(debt)/1000000,2) total_debt
from [Portfolio Projects]..international_debt


--Looking at the the country with the highest debt and amount of the debt
Select country_name, sum(debt) total_debt
From [Portfolio Projects]..international_debt
Group by country_name
Order by 2 desc


--Looking at the average amount of debt owed by the top 10 countries across different debt indicators
--Using with statement
with debt_rows as (
Select distinct(indicator_code) as debt_indicator,indicator_name, avg(debt) over (partition by indicator_code) average_debt
From [Portfolio Projects]..international_debt
)

Select top 10*
From debt_rows
Order by 3 desc

--Looking at the average amount of debt owed by the top 10 countries across different debt indicators
Select indicator_code as debt_indicator, indicator_name, avg(debt) avg_debt
From [Portfolio Projects]..international_debt
Group by indicator_code, indicator_name
Order by 3 desc 


--Looking at the most common debt indicators
Select indicator_code, count(indicator_code) total_indicator_count
From [Portfolio Projects]..international_debt
Group by indicator_code
Order by 2 desc


--Looking at the distinct debt indicators
Select distinct(indicator_name) distinct_debt_indicator, indicator_code
From [Portfolio Projects]..international_debt


--Looking at the highest amount of principal repayments 
Select country_name, indicator_name, debt
From [Portfolio Projects]..international_debt
Where debt = (Select MAX(debt)
From [Portfolio Projects]..international_debt
where indicator_code = 'DT.AMT.DLXF.CD')


--Finding out the maximum amount of debt that each country has 
Select distinct(country_name), MAX(debt) over (partition by country_name) maximum_debt
From [Portfolio Projects]..international_debt
Order by 2 desc




--END