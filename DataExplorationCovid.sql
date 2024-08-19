
Select *
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is not null
order by 3,4

--Select *
--From PortfolioProjectDataExploration..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectDataExploration..CovidDeaths
Where location like '%portugal%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectDataExploration..CovidDeaths
Where location like '%portugal%'
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, date, total_cases, population, (total_cases/population)*100 as PopulationGotCovid
From PortfolioProjectDataExploration..CovidDeaths
Where location like '%portugal%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjectDataExploration..CovidDeaths
-- Where location like '%portugal%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is not null
Group by Location
Order by TotalDeathCount desc


-- Showing by continent

Select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is not null
Group by Continent
Order by TotalDeathCount desc

-- More accurate

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is null
Group by Location
Order by TotalDeathCount desc


-- Showing continentes with the highest death count per population

Select Continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is not null
Group by Continent
Order by TotalDeathCount desc


-- Global numbers

Select SUM(New_cases) as Total_cases, SUM(cast(New_deaths as int)) as Total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProjectDataExploration..CovidDeaths
Where Continent is not null
Order by 1, 2


-- Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVacccinated
--,	(RollingPeopleVacccinated/Population)*100
From PortfolioProjectDataExploration..CovidDeaths dea
Join PortfolioProjectDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


-- USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVacccinated
--,	(RollingPeopleVacccinated/Population)*100
From PortfolioProjectDataExploration..CovidDeaths dea
Join PortfolioProjectDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From PopVsVac
Where location like '%portugal%'



-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Data datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVacccinated
--,	(RollingPeopleVacccinated/Population)*100
From PortfolioProjectDataExploration..CovidDeaths dea
Join PortfolioProjectDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
	dea.date) as RollingPeopleVacccinated
--,	(RollingPeopleVacccinated/Population)*100
From PortfolioProjectDataExploration..CovidDeaths dea
Join PortfolioProjectDataExploration..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated