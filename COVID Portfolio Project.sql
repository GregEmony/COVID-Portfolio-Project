
Select *
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From [Portfolio Covid Project]..CovidVaccinations
--Order by 3,4

Select Location,date,total_cases,new_cases,total_deaths, population
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Order by 1,2

-- Total Cases vs Total Deaths to show death percentage

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Covid Project]..CovidDeaths
Where location like '%state%'
and continent is not null
Order by 1,2

-- Total cases vs Population to see percentage of population 

Select Location,date,population,total_cases,(total_deaths/population)*100 as DeathPercentage
From [Portfolio Covid Project]..CovidDeaths
--(Where location like '%state%')
Order by 1,2

--Countries with the highest infection rate by population
Select Location,population,MAX(total_cases) as HighestInfection,MAX(total_deaths/total_cases)*100 as PercentPopulationInfected
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Group by Location, Population 
Order by PercentPopulationInfected desc


-- Highest Death Count by Population 
Select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Group by Location, Population 
Order by TotalDeathCount desc

-- Highest Death Count by Continent 
Select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Group by continent 
Order by TotalDeathCount desc


-- 

Select date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Group by date
Order by 1,2 

-- Total deaths in the world

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Covid Project]..CovidDeaths
Where continent is not null
Order by 1,2 


--Joining both tables together 
-- Total Population vs Vaccinations

Select *
From [Portfolio Covid Project]..CovidDeaths dea
Join [Portfolio Covid Project]..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date


  -- Using CTE
With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) Over(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Covid Project]..CovidDeaths dea
Join [Portfolio Covid Project]..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac 


-- Temporary Table ( Exercise )

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
 ( 
Continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) Over(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Covid Project]..CovidDeaths dea
Join [Portfolio Covid Project]..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

--Preparing View for Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) Over(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From [Portfolio Covid Project]..CovidDeaths dea
Join [Portfolio Covid Project]..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null

