--SELECT *
--FROM portfolioproject.dbo.covidvax
--ORDER BY 3,4

SELECT *
FROM portfolioproject..coviddeaths
ORDER BY 3,4

SELECT location ,date ,total_cases ,new_cases ,total_deaths ,population
FROM portfolioproject..coviddeaths
ORDER BY 1,2
--country based death percentage of total cases
SELECT location ,date ,total_cases ,total_deaths , (total_deaths/total_cases)*100 as death_percentage
FROM portfolioproject..coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--total cases vs population
SELECT location ,date ,total_cases ,population, (total_cases/population)*100 as affected_population_percentage 
FROM portfolioproject..coviddeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--coutries with highest affected population
SELECT location ,population  ,max(total_cases) as high_infection_count ,max( (total_cases/population))*100 as affected_population_percentage
FROM portfolioproject..coviddeaths
--WHERE location LIKE '%India%'
group by location,population
ORDER BY affected_population_percentage desc

--countrys with highest death per population BY COUNTRY
SELECT location ,max(cast (total_deaths as int)) as highest_death
FROM portfolioproject..coviddeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
group by location
ORDER BY highest_death desc

--countrys with highest death per population BY CONTINENT
SELECT location,max(cast (total_deaths as int)) as highest_death
FROM portfolioproject..coviddeaths
--WHERE location LIKE '%India%'
WHERE continent IS  NULL
AND location NOT IN ('World','European Union','International')
group by location
ORDER BY highest_death desc
 
 --WORLD DEATH PERCENTAGE BY DATE
 SELECT  SUM(new_cases) as total_cases_day,SUM(CAST(new_deaths as INT)) as total_deaths_day,SUM(CAST(new_deaths as INT))*100/SUM(new_cases)  as death_percentage
FROM portfolioproject..coviddeaths
--WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2 desc

-- increasing vaccination percentage based on country
WITH  popvax (continent ,location ,date ,population ,new_vaccinations,incresing_vax)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations
,SUM(convert (INT,vax.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location ,dea.date) as 
incresing_vax
FROM portfolioproject .. coviddeaths as dea
JOIN portfolioproject..covidvax as vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * ,(incresing_vax/population)*100 as increasing_vax_percentage
FROM popvax
--WHERE location LIKE '%India%'

-- create view for vax percent population
CREATE VIEW percentpopulation AS
SELECT dea.continent,dea.location,dea.date,dea.population,vax.new_vaccinations
,SUM(convert (INT,vax.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location ,dea.date) as 
incresing_vax
FROM portfolioproject .. coviddeaths as dea
JOIN portfolioproject..covidvax as vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM percentpopulation 

--increasing test percentage per country
WITH  poptest (continent ,location ,date ,population ,new_tests,incresing_tests)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vax.new_tests
,SUM(convert (INT,vax.new_tests)) OVER(PARTITION BY dea.location ORDER BY dea.location ,dea.date) as 
incresing_tests
FROM portfolioproject .. coviddeaths as dea
JOIN portfolioproject..covidvax as vax
	ON dea.location = vax.location
	AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * ,(incresing_tests/population)*100 as increasing_test_percentage
FROM poptest

--WHERE location LIKE '%India%'

--relation between death percentage vs aged above 65 by country
SELECT dea.location ,max( (dea.total_deaths/population))*100 as death_percentage
,max( (vax.aged_65_older/population))*100 as population_above65_percentage
FROM portfolioproject .. coviddeaths as dea
JOIN portfolioproject..covidvax as vax
	ON dea.location = vax.location
	AND dea.date = vax.date
--WHERE location LIKE '%India%'
WHERE dea.total_deaths IS NOT NULL
AND vax.aged_65_older IS NOT NULL
group by dea.location,dea.population
ORDER BY population_above65_percentage desc

--relation between death percentage vs diabetes by country
SELECT dea.location ,max( (dea.total_deaths/population))*100 as death_percentage
,max( (vax.diabetes_prevalence/population))*100 as diabetes_population_percentage

FROM portfolioproject .. coviddeaths as dea
JOIN portfolioproject..covidvax as vax
	ON dea.location = vax.location
	AND dea.date = vax.date
--WHERE location LIKE '%India%'
WHERE dea.total_deaths IS NOT NULL
AND vax.diabetes_prevalence IS NOT NULL

group by dea.location,dea.population
ORDER BY diabetes_population_percentage desc

--relation between death percentage vs diabetes and aged above 65 by country
SELECT dea.location ,max( (dea.total_deaths/total_cases))*100 as death_percentage
,max( (vax.diabetes_prevalence/population))*1000000 as diabetes_population_per_million
,max( (vax.aged_65_older/population))*1000000 as population_above65_per_million
FROM portfolioproject .. coviddeaths as dea
JOIN portfolioproject..covidvax as vax
	ON dea.location = vax.location
	AND dea.date = vax.date
--WHERE location LIKE '%India%'
WHERE dea.total_deaths IS NOT NULL
AND vax.diabetes_prevalence IS NOT NULL
AND vax.aged_65_older IS NOT NULL
group by dea.location,dea.population
ORDER BY death_percentage desc