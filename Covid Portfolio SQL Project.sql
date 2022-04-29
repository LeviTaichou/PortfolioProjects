SELECT *
FROM PortfolioProject . .CovidDeaths 
order by 1,2

--SELECT *
--FROM PortfolioProject . .CovidVaccinations
--order by 1,2

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject . .CovidDeaths 
order by 1,2

-- Looking at the Total Cases vs Total Deaths	
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject . .CovidDeaths 
WHERE location like '%Philippines%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of the population got Covid

SELECT Location, date, population, total_cases,  (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject . .CovidDeaths 
--WHERE location like '%Philippines%'
order by 1,2

-- Looking at countries with Highest Infection Rates compared to Populations


SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX ((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject . .CovidDeaths 
-- WHERE location like '%Philippines%'
Group by Location, population
order by 4 DESC

-- Showing countries with the Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject . .CovidDeaths 
WHERE continent is not Null
-- WHERE location like '%Philippines%'
Group by Location
order by TotalDeathCount  DESC

-- BREAK DOWN BY CONTINENT
-- Showing continents with the Highest Death Count per population	

SELECT continent, MAX(cast(total_deaths as int))as TotalDeathCount
FROM PortfolioProject . .CovidDeaths 
WHERE continent is not Null
-- WHERE location like '%Philippines%'
Group by continent
order by TotalDeathCount  DESC


-- GLOBAL NUMBERS

SELECT  date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject . .CovidDeaths 
---WHERE location like '%Philippines%'
where  continent is not null
group by date 
order by 1,2

-- GLOBAL TOTAL FOR 2020

SELECT   SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 AS DeathPercentage
FROM PortfolioProject . .CovidDeaths 
---WHERE location like '%Philippines%'
where  continent is not null
-- group by date 
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject . .CovidDeaths dea
JOIN PortfolioProject . .CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where  dea.continent is not null
order by 2,3


-- CTE OPTION  

With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject . .CovidDeaths dea
JOIN PortfolioProject . .CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where  dea.continent is not null
--order by 2,3
)	

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopVsVac


-- TEMP TABLE 

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject . .CovidDeaths dea
JOIN PortfolioProject . .CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where  dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated	 as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM PortfolioProject . .CovidDeaths dea
JOIN PortfolioProject . .CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where  dea.continent is not null
--order by 2,3