SELECT location, date,total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--
SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%africa%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--shows what percentage of population got covid

SELECT location, date,total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%africa%'
ORDER BY 1,2

--looking at countries with highest infrection rate compared to population

SELECT location, 
       population, 
       MAX(total_cases) AS HighestInfectioncount, 
       MAX((total_cases / population) * 100) AS PercentPopulationInfected
FROM CovidDeaths
-- WHERE location LIKE '%africa%'
GROUP BY location, population
ORDER BY location, HighestInfectioncount 


--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,  
       MAX(total_deaths) AS TotalDeathcount
FROM CovidDeaths
-- WHERE location LIKE '%africa%'
GROUP BY location
ORDER BY TotalDeathcount DESC

--CONTINENT

SELECT continent,  
       MAX(CAST(total_deaths AS INT)) AS TotalDeathcount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount DESC

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent,  
       MAX(CAST(total_deaths  AS INT)) AS TotalDeathcount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathcount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATIONS
--use cte

WITH PopvsVac (Continent, location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(260),
Location nvarchar(260),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 1,2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




--creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3