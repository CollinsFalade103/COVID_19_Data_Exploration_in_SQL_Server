SELECT *
FROM  PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4


---Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



--SELECT *
--FROM  PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT   Location,date, total_cases,new_cases, total_deaths, population
FROM     PortfolioProject..CovidDeaths 
ORDER BY 1,2


-- Select Data that we are going to be starting with

SELECT   Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM     PortfolioProject..CovidDeaths 
WHERE    Location LIKE '%state%'
         AND continent IS NOT NULL
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT   Location,date, total_cases, population, (total_deaths/total_cases)*100 AS PrecentofPopulationInfected
FROM     PortfolioProject..CovidDeaths 
WHERE    Location LIKE '%state%'
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid


SELECT   Location, population, MAX(total_cases) AS HighestInfectionCount, MAX( (total_deaths/total_cases))*100 AS PercentageofPopulationInfected
FROM     PortfolioProject..CovidDeaths 
WHERE    continent IS NOT NULL
GROUP BY  location, population
ORDER BY  PercentageofPopulationInfected DESC


-- Countries with Highest Infection Rate compared to Population

SELECT    SUM(new_cases)AS total_cases, SUM (CAST (new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM     PortfolioProject..CovidDeaths 
--WHERE    location LIKE '%states%'
WHERE    continent IS NOT NULL
--GROUP BY date 
ORDER BY 1,2




-- Countries with Highest Death Count per Population



SELECT   continent, MAX(CAST(total_deaths AS INT )) AS TotalDeathCount
FROM     PortfolioProject..CovidDeaths 
--WHERE location LIKE '%state%'
WHERE    continent IS NOT  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT   continent, MAX(CAST(total_deaths AS INT )) AS TotalDeathCount
FROM     PortfolioProject..CovidDeaths 
--WHERE location LIKE '%state%'
WHERE    continent IS NOT  NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--Global Numbers

SELECT   date, SUM(new_cases)AS total_cases, SUM (CAST (new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM     PortfolioProject..CovidDeaths 
--WHERE    location LIKE '%states%'
WHERE    continent IS NOT NULL
GROUP BY date 
ORDER BY 1,2

 -- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition By in previous query



WITH PopvsVac (continent,Location,date,Population,new_vaccinations,RollingPeopleVaccinated)
AS
(

SELECT  Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
        SUM (CAST(vac.new_vaccinations  AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS
		RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
FROM    PortfolioProject..CovidDeaths Dea
JOIN    PortfolioProject..CovidVaccinations Vac
        ON Dea.location = Vac.location
		AND Dea.date = Vac.date
WHERE   Dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT  *,(RollingPeopleVaccinated/Population)*100
FROM  PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query



DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location  nvarchar(255),
Date      DateTime,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)
INSERT INTO  #PercentPopulationVaccinated
SELECT       Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
             SUM (CAST(vac.new_vaccinations  AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS
		     RollingPeopleVaccinated
		  --,(RollingPeopleVaccinated/population)*100
FROM         PortfolioProject..CovidDeaths Dea
JOIN         PortfolioProject..CovidVaccinations Vac
             ON Dea.location = Vac.location
		     AND Dea.date = Vac.date
WHERE
        Dea.continent IS NOT NULL
--           ORDER BY 2,3

SELECT       *,(RollingPeopleVaccinated/Population)*100
FROM         #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW  PercentPopulationVaccinated AS 
SELECT  Dea.continent,Dea.location,Dea.date,Dea.population,Vac.new_vaccinations,
        SUM (CAST(vac.new_vaccinations  AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS
		RollingPeopleVaccinated
		--,(RollingPeopleVaccinated/population)*100
FROM    PortfolioProject..CovidDeaths Dea
JOIN    PortfolioProject..CovidVaccinations Vac
        ON Dea.location = Vac.location
		AND Dea.date = Vac.date
WHERE   Dea.continent IS NOT NULL
--ORDER BY 2,3



