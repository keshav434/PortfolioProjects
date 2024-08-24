Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2  -- Basically provided the similar content for column 1 and 2 (based on Location and Date)

--looking at Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, 
CASE 
        WHEN total_cases = 0 THEN NULL 
        ELSE (total_deaths / total_cases)*100 END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null and WHERE location like '%india%'
ORDER BY 1, 2;


--looking at total cases vs population
SELECT Location, date, population, total_cases,  
CASE 
        WHEN total_cases = 0 THEN NULL 
        ELSE ( total_cases/ population)*100 END AS PercentageInfected
FROM PortfolioProject..CovidDeaths
where continent is not null and location like '%india%'
ORDER BY 1, 2;


--looking at countries with highest infection rate
SELECT Location, population, Max(total_cases)
as HighestInfectionCount, MAX(total_cases/ population)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, population
where continent is not null
--WHERE location like '%india%'
ORDER BY PercentagePopulationInfected desc


--looking at countries with highest Death rate per population
SELECT Location, population, Max(cast(total_deaths as int))
as TotalDeathCount, MAX(total_deaths/ population)*100 AS PercentagePopulationDeath
FROM PortfolioProject..CovidDeaths
Group by Location, population
where continent is not null
--WHERE location like '%india%'
ORDER BY PercentagePopulationDeath desc


--looking at countries with highest Death rate per population
SELECT continent, Max(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by continent 
--WHERE location like '%india%'
ORDER BY TotalDeathCount desc

-- WHY THE VALUE CHANGED


--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases ,SUM(cast(new_deaths as int)) as total_deaths,	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--Group By date
order by 1,2

-- total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) AS total_vaccinations  -- Convert and sum
,(total_vaccinations/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations  vac
   On dea.location = vac.location
   and dea.date =vac.date
where dea.continent is not null
order by 2,3

--USE CTE

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,  
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations  
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    --WHERE 
       -- dea.continent IS NOT NULL
)
SELECT 
    *, 
    CASE 
        WHEN population = 0 THEN NULL  
        ELSE (total_vaccinations * 1.0 / population) * 100  
    END AS vaccination_percentage
FROM 
    PopvsVac
ORDER BY 
    location, date;



DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    continent nvarchar(225),
    location nvarchar(225),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    total_vaccinations numeric
);
INSERT INTO #PercentPopulationVaccinated
(
    continent,
    location,
    date,
    population,
    new_vaccinations,
    total_vaccinations
)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE 
    --dea.continent IS NOT NULL;
SELECT 
    *, 
    CASE 
        WHEN population = 0 THEN NULL  
        ELSE (total_vaccinations * 1.0 / population) * 100  
    END AS vaccination_percentage
FROM 
    #PercentPopulationVaccinated
ORDER BY 
    location, date;


--Creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinat AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


SELECT TOP 10 *
FROM PercentPopulationVaccinates;



SELECT * 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinates';


USE PortfolioProject;
GO

SELECT * 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinates';


SELECT *
FROM sys.objects
WHERE type = 'V' AND name = 'PercentPopulationVaccinates';


SELECT * 
FROM dbo.PercentPopulationVaccinates;

SELECT * 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinates';
SELECT DB_NAME() AS CurrentDatabase;


USE PortfolioProject;
GO
USE master;
GO
DROP VIEW IF EXISTS dbo.PercentPopulationVaccinates;

USE PortfolioProject;
GO

CREATE VIEW dbo.PercentPopulationVaccinates AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    CAST(vac.new_vaccinations AS BIGINT) AS new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
   AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


USE PortfolioProject;
GO

SELECT * 
FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME = 'PercentPopulationVaccinates';

USE PortfolioProject;
GO

SELECT TOP 10 * 
FROM dbo.PercentPopulationVaccinates;

