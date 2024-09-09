/*

--DATA EXPLORATION IN SQL 


*/


SELECT*
FROM [Portfolio Projects]..CovidVaccinations
ORDER BY 3,4

SELECT *
FROM [Portfolio Projects]..CovidDeathData

-------------------------------------------------------------------------------------------------------------------
--SELECTING COLUMNS FOR EXPLORATION

SELECT Location,Date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Projects]..CovidDeathData
ORDER BY 1,2




--------------------------------------------------------------------------------------------------------------------
--LOOKING AT TOTAL CASES VS TOTAL DEATHS

SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as numeric)/total_cases)*100 as DeathPercentage
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like '%states'
--and total_cases is not null and continent is not null and total_deaths is not null
--GROUP BY Location, date, total_cases, total_deaths
ORDER BY 1,2



---------------------------------------------------------------------------------------------------------------------
--LOOKING AT TOTAL CASES VS POPULATION


SELECT Location, date, total_cases, population, (cast(total_cases as numeric)/population)*100 as DeathPercentage
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'u%states'
where total_cases is not null and continent is not null
--GROUP BY Location, date, total_cases, total_deaths
ORDER BY 1,2,3












----------------------------------------------------------------------------------------------------------------------
--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION


SELECT Location, population, max(total_cases) HighestInfectionCount, (max(total_cases)/population)*100 PercentPopulationInfected
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE Continent is not null
GROUP BY Location, population
ORDER BY 4 desc










-----------------------------------------------------------------------------------------------------------------------
--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 


SELECT Location, max(cast(total_deaths as numeric)) TotalDeathCount
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE Continent is not null
GROUP BY Location
ORDER BY 2 desc














------------------------------------------------------------------------------------------------------------------------
--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, max(cast(total_deaths as numeric)) TotalDeathCount
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE continent is null
GROUP BY location
ORDER BY 2 desc




-----------------------------------------------------------------------------------------------------------------------
--GLOBALNUMBERS
--TOTAL VALUES OF NEW CASES/NEW DEATHS ACROSS THE WORLD

--PER DAY
SELECT date, sum(new_cases) totalnewcases, sum(cast(new_deaths as numeric)) totalnewdeaths, sum(cast(new_deaths as numeric))/sum(new_cases)*100 NewDeathPercentage
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE Continent is not null and new_cases is not null and new_deaths is not null
GROUP BY date
ORDER BY 1,2


--OVERALL
SELECT /*date*/ sum(new_cases) totalnewcases, sum(cast(new_deaths as numeric)) totalnewdeaths, sum(cast(new_deaths as numeric))/sum(new_cases)*100 NewDeathPercentage
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE Continent is not null
--GROUP BY date
ORDER BY 1 


------------------------------------------------------------------------------------------------------------------------
--LOOKING AT TOTAL POPULATION VS VACCINATIONS

--TOTAL POPULATION VS NEW VACCINATIONS
SELECT de.location, de.date, de.population, va.new_vaccinations
FROM [Portfolio Projects]..CovidDeathData de
JOIN [Portfolio Projects]..CovidVaccinations va
	ON de.date = va.date
	and de.location = va.location
WHERE de.continent is not null and va.new_vaccinations is not null
ORDER BY 1,2


--TOTAL POPULATION VS TOTAL VACCINATIONS 
--USING A ROLLING COUNT
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, sum(convert(numeric,va.new_vaccinations)) over(partition by de.location
 order by de.location,de.date) RollingNewVaccinations
FROM [Portfolio Projects]..CovidDeathData de
JOIN [Portfolio Projects]..CovidVaccinations va
	ON de.date = va.date
	and de.location = va.location
WHERE de.continent is not null 
ORDER BY 2,3




--TOTAL POPULATION VS VACCINATIONS
--USING SUBQUERY

SELECT *, (RollingNewVaccinations/population)*100 
FROM (
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, sum(convert(numeric,va.new_vaccinations)) over(partition by de.location
 order by de.location,de.date) RollingNewVaccinations
FROM [Portfolio Projects]..CovidDeathData de
JOIN [Portfolio Projects]..CovidVaccinations va
	ON de.date = va.date
	and de.location = va.location
WHERE de.continent is not null 
) as PopVsVac



--USING TEMP TABLES

DROP TABLE IF EXISTS #POPvsVAC
CREATE TABLE #POPvsVAC
(Continent varchar(150),
Location varchar (150),
Date Datetime,
Population bigint,
New_Vaccinations bigint,
RollingNewVaccinations NUMERIC,
)



INSERT INTO #POPvsVAC
SELECT * 
FROM (
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, sum(convert(numeric,va.new_vaccinations)) over(partition by de.location
 order by de.location,de.date) RollingNewVaccinations
FROM [Portfolio Projects]..CovidDeathData de
JOIN [Portfolio Projects]..CovidVaccinations va
	ON de.date = va.date
	and de.location = va.location
WHERE de.continent is not null 
) as PopVsVac

SELECT *,  (RollingNewVaccinations/population)*100 PercentPopulationVaccinated
FROM #POPvsVAC
ORDER BY 2,3




----------------------------------------------------------------------------------------------------------------------------
--CREATING VIEW TO STORE FOR FUTURE VISUALIZATIONS

CREATE VIEW NEWCASES_NEWDEATHS AS
SELECT /*date*/ sum(new_cases) totalnewcases, sum(cast(new_deaths as numeric)) totalnewdeaths, sum(cast(new_deaths as numeric))/sum(new_cases)*100 NewDeathPercentage
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE Continent is not null
--GROUP BY date
--ORDER BY 1 


CREATE VIEW TOTALPOPULATION_vs_VACCINATIONS AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, sum(convert(numeric,va.new_vaccinations)) over(partition by de.location
 order by de.location,de.date) RollingNewVaccinations
FROM [Portfolio Projects]..CovidDeathData de
JOIN [Portfolio Projects]..CovidVaccinations va
	ON de.date = va.date
	and de.location = va.location
WHERE de.continent is not null 
--ORDER BY 2,3


CREATE VIEW CONTINENTSTOTALDEATHS AS
SELECT location, max(cast(total_deaths as numeric)) TotalDeathCount
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE continent is null
GROUP BY location
--ORDER BY 2 desc


CREATE VIEW COUNTRIESTOTALDEATHS AS
SELECT Location, max(cast(total_deaths as numeric)) TotalDeathCount
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'N%ria'
--and total_cases is not null and total_deaths is not null
WHERE Continent is not null
GROUP BY Location
--ORDER BY 2 desc


CREATE VIEW COUNTRIES_TOTALCASESvsDEATHS AS
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as numeric)/total_cases)*100 as DeathPercentage
FROM [Portfolio Projects]..CovidDeathData




CREATE VIEW TOTALCASES_vs_POPULATION AS
SELECT Location, date, total_cases, population, (cast(total_cases as numeric)/population)*100 as DeathPercentage
FROM [Portfolio Projects]..CovidDeathData
--WHERE location like 'u%states'
where total_cases is not null and continent is not null
--GROUP BY Location, date, total_cases, total_deaths
--ORDER BY 1,2,3









----------------------------------------------------------------------------------------------------------------------------
																								--BY AKAGHA COLLINS