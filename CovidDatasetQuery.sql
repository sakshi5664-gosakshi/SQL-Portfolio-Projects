--CovidDeath Database queries

Select * 
from CovidDataset..CovidDeaths
where continent is not null
order by 3, 4;



-- Selecting the data we are going to use

Select Location, date, total_cases, new_cases, total_deaths ,population
from CovidDataset..CovidDeaths
where continent is not null
order by 1, 2;



-- Looking at Total Cases vs. Total Deaths
-- Shows liklihood of dying in UNITED STATES

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from CovidDataset..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2;



-- Looking at the Total Cases vs. Population
-- Shows liklihood of infected population in INDIA

Select Location, date, Population, total_cases, (total_cases/Population)*100 AS TotalPercentage
from CovidDataset..CovidDeaths
where location like '%India%'
and continent is not null
order by 1, 2;



-- Looking at the Total Cases vs. Population
-- Shows what percentage of POPULATION got COVID for every LOCATION

Select Location, date, Population, total_cases, (total_cases/Population)*100 AS PercentPopulationInfected
from CovidDataset..CovidDeaths
where continent is not null
order by 1, 2;



-- Looking at COUNTRIES with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentPopulationInfected
from CovidDataset..CovidDeaths
where continent is not null
group by Location, Population
order by PercentPopulationInfected desc;



-- Showing Countries with Highest Death Count as per Population

Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDataset..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc;



-- LET'S BRAEK THINGS DOWN BY CONTINENTS
-- Showing continents with the highest death count as per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDataset..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select date, SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) as SumOfNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDataset..CovidDeaths
where continent is not null
group by date
order by 1, 2;



-- GLOBAL New cases, New deaths and Death percentage

Select SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) as SumOfNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDataset..CovidDeaths
where continent is not null
order by 1, 2;



--CovidVaccinations Database queries

Select * 
from CovidDataset..CovidVaccinations;



-- Looking all the data available in both the tables

Select * 
from CovidDataset..CovidDeaths dea
JOIN CovidDataset..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date;



-- Looking Total population VS. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDataset..CovidDeaths dea
JOIN CovidDataset..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not NULL
order by 2, 3;



-- USE CTE

With PopVsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDataset..CovidDeaths dea
JOIN CovidDataset..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac



-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
);


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDataset..CovidDeaths dea
JOIN CovidDataset..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100 as PercentOfPeopleVaccinated
from #PercentPopulationVaccinated



-- Creating VIEW to store data for VISUALIZATIONS

-- PercentPopulationVaccinated VIEW

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDataset..CovidDeaths dea
JOIN CovidDataset..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null


-- SELECTING PercentPopulationVaccinated VIEW

Select * from PercentPopulationVaccinated


-- TotalDeathCount VIEW

Create View TotalDeathCount as
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDataset..CovidDeaths
where continent is not null
group by continent


-- SELECTING TotalDeathCount VIEW

Select * from TotalDeathCount;