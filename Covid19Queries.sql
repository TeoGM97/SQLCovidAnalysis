--Select Data that we are going to be using

Select location, date, total_cases/10, new_cases/10, total_deaths/10, population/10
From Covid19Project..CovidDeaths
Order by 1, 2


-- Total Cases vs Total Deaths: Percentage of infected people who died in Colombia
	-- Shows the likeliohood of dying if toy contract covid in your country
Select location, date, new_cases, total_cases, total_deaths, new_deaths, (total_deaths/total_cases)*100 as death_percentage
From Covid19Project..CovidDeaths
Where location like '%colombia%'
Order by 1, 2


-- Total Cases vs Population
	-- Shows what percentage of population got Covid in Colombia

Select location, date, total_cases, population, (total_cases/population)*100 as percentage_population_infected
From Covid19Project..CovidDeaths
Where location like '%colombia%'
Order by 1, 2


-- Countries with highest infection rates vs Population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percentage_population_infected
From Covid19Project..CovidDeaths
Where location like '%colo%'
Group by location, population
Order by percentage_population_infected desc


-- Countries with highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From Covid19Project..CovidDeaths
--Where location like '%colo%'
Where continent is not null -- only countries
Group by location
Order by total_death_count desc


-- Breaking count by continent
Select location, MAX(cast(total_deaths as int)) as total_death_count
From Covid19Project..CovidDeaths
--Where location like '%colo%'
Where continent is null -- only countries
Group by location
Order by total_death_count desc

--
-- GLOBAL NUMBERS

--Total cases
Select 
	sum(new_cases) as total_cases, 
	sum(new_deaths) as total_deaths, 
	CASE WHEN SUM(new_cases) <> 0
		THEN (SUM(new_deaths) * 100.0) / SUM(new_cases)
		ELSE 0
    END AS deaths_percentage 
From Covid19Project..CovidDeaths
Where continent is not null
--Group by date
Order by 1, 2

--Total cases per day
Select date,
	sum(new_cases) as total_cases, 
	sum(new_deaths) as total_deaths, 
	CASE WHEN SUM(new_cases) <> 0
		THEN (SUM(new_deaths) * 100.0) / SUM(new_cases)
		ELSE 0
    END AS deaths_percentage 
From Covid19Project..CovidDeaths
Where continent is not null
Group by date
Order by 1, 2

--
-- Joining CovidDeaths and CovvidVaccinations data bases
Select *
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations
	--Rolling count of people vaccinated day by day in each country
 Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations) OVER (Partition by vac.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 ==> Can't be unsed because it was just created. Will use CTE
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
-- This query will be inside of the CTE. Will be below:


-- Use CTE to see percentage
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations) OVER (Partition by vac.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 ==> Can't be unsed because it was just created. Will use CTE
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentOfVaccinatedPeople
From PopvsVac

--
-- TEMP TABLE