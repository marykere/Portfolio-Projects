/*COVID DEATHS AND VACCINATIONS DATA EXPLORATION
*/

select *
from portfolio_project..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

select *
from portfolio_project.dbo.CovidVaccinations
ORDER BY 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..CovidDeaths
ORDER BY 1,2;

-- Looking total_cases versus total_deaths in Kenya and United States: Shows likelihood of dying  if a person contracts COVID in their country

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
from portfolio_project..CovidDeaths
WHERE location LIKE '%kenya%'
ORDER BY 1,2 DESC;

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
from portfolio_project..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2 DESC;

-- Looking at the total_cases vs Population: shows what population got COVID

select location, date, total_cases,population, (total_cases/population)*100 AS CovidContracted_Percentage 
from portfolio_project..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2 DESC;

-- Looking at countries with highest infection rates compared to population 

select location, MAX(total_cases) AS HighestInfectionCount,population, MAX(total_cases/population)*100 AS PopulationInfected_Percentage 
from portfolio_project..CovidDeaths
GROUP BY population, location
ORDER BY PopulationInfected_Percentage  DESC; 

-- Showing countries with the highest death count per population 

select location, MAX(CAST(total_deaths as int)) AS totaldeathcount 
from portfolio_project..CovidDeaths
WHERE continent is not null
GROUP BY  location
ORDER BY totaldeathcount  DESC; 

-- Showing continents with highest death counts per population

select location, MAX(CAST(total_deaths as int)) AS totaldeathcount 
from portfolio_project..CovidDeaths
WHERE continent is null
GROUP BY  location
ORDER BY totaldeathcount  DESC; 

-- GLOBAL NUMBERS 

SELECT 
    location, 
    date,
    SUM(CAST(total_cases AS int)) OVER (PARTITION BY location, date) AS Total_Cases,
    SUM(CAST(total_deaths AS int)) OVER (PARTITION BY location, date) AS Total_Deaths,
    (SUM(CAST(total_deaths AS int)) OVER (PARTITION BY location, date) / 
     SUM(CAST(total_cases AS int)) OVER (PARTITION BY location, date)) * 100 AS DeathPercentage
FROM portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

select SUM(new_cases) AS total_cases , SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
from portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

/*Looking at Total Population vs Vaccination
*/

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 1,2,3;

   -- USING A CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, RollingPeopleVaccinated/Population*100
FROM PopvsVac
ORDER BY 1,2;

  -- CREATING A TEMP TABLE

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null

SELECT *, RollingPeopleVaccinated/Population*100
FROM #PercentPopulationVaccinated 
ORDER BY 1,2;



	-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths dea 
JOIN portfolio_project..CovidVaccinations vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated 