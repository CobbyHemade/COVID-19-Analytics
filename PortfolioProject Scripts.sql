Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths
--Shows the likehood of dying if you attract covid in your country
Select Location, date, total_cases, total_deaths,(total_deaths / total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at the total cases vs the population
Select Location, date, total_cases, population,(total_deaths / population)*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))*100 as PercentOfPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location, Population
order by PercentOfPopulationInfected DESC

--LETS BREAK THINGS BY CONTINENT

--Showing countries with highest death counts per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2



--USE CTE
with PopvsVac (Continent, location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as(
SELECT dea.continent, dea.location, CONVERT(datetime, dea.date, 105) AS date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND CONVERT(datetime, dea.date, 105) = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, CONVERT(datetime, dea.date, 105)
)
Select *, (RollingPeopleVaccinated/population) *100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPeopleVaccinated
CREATE Table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPeopleVaccinated
SELECT dea.continent, dea.location, CONVERT(datetime, dea.date, 105) AS date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND CONVERT(datetime, dea.date, 105) = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY dea.location, CONVERT(datetime, dea.date, 105)


Select *, (RollingPeopleVaccinated/population) *100
From #PercentPeopleVaccinated

--Creating View to store data for later Visualisation

Create View PercentPeopleVaccinated1 as
Select dea.continent, dea.location, CONVERT(datetime, dea.date, 105) AS date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population) *100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND CONVERT(datetime, dea.date, 105) = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY dea.location, CONVERT(datetime, dea.date, 105)


Select * 
from PercentPeopleVaccinated1