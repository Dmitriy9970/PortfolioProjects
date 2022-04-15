Select *
From PortfolioProject..['CovidDeaths']
Where continent is not NULL
order by 3,4


--Select *
--From PortfolioProject..[CovidVaccinations]
--order by 3,4

--Select data that we are going to be uisng

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..['CovidDeaths']
Where continent is not NULL
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in Kazakhstan
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
Where location like 'Kazakhstan'
Where continent is not NULL
order by 1,2

--Looking at total cases vs population
--Show what percentage of population got covid

Select location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths']
Where location like 'Kazakhstan'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['CovidDeaths']
--Where location like 'Kazakhstan'
Group by Location, population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
--Where location like 'Kazakhstan'
Where continent is not NULL
Group by Location
order by TotalDeathCount desc

--Breaking things down by continent



--Showing continents with highest death counts per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..['CovidDeaths']
--Where location like 'Kazakhstan'
Where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths']
--Where location like 'Kazakhstan'
Where continent is not NULL
--Group by date
order by 1,2



--Looking at Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations))  OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not NULL
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)

as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations))  OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp table

Create table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vacciantions numeric,
RollingPeopleVaccinated numeric
)



Insert into #PrecentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations))  OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PrecentPopulationVaccinated

--Creating View to store data for later visualizations

Create view PrecentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations))  OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject..['CovidDeaths'] dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not NULL
--order by 2,3


