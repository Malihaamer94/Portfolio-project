Select *
From [portfolio project]..CovidDeaths
order by 3,4


Select Location,date,total_cases,new_cases,total_deaths,population
From [portfolio project]..CovidDeaths
order by 1,2

--looking at total Cases vs total Deaths
--shows likelihood of dying if you contract covid in your country
Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From [portfolio project]..CovidDeaths
where location like '%germany%'
order by 1,2


--looking at totl cases vs population
--shows what percentage of population got covid
Select Location,date,total_cases,population, (total_cases/population)*100 as CovidPercentage
From [portfolio project]..CovidDeaths
where location like '%germany%'
order by 1,2

--looking at countries with highest infection rate
Select Location,MAX(total_cases) as HighestInfetionCount ,population, MAX(total_cases/population)*100 as CovidPercentage
From [portfolio project]..CovidDeaths
GROUP by location,population
order by CovidPercentage desc

--showing the countries with highest deathcoun per population
Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths
Where continent is not null
GROUP by location
order by TotalDeathCount desc

--lets breake things down by continent

--showing the continents with heighest death count
Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths
Where continent is not null
GROUP by continent
order by TotalDeathCount desc

--Global Numbers
Select date,SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths
--where location like '%germany%'
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccination
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(cast(CovidVaccinations.new_vaccinations as int)) OVER (Partition by CovidDeaths.location,CovidDeaths.Date) as RollingPeopleVaccinated
From  [portfolio project] ..CovidDeaths
join [portfolio project]..CovidVaccinations
  On CovidDeaths.location = CovidVaccinations.location
  and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3


--Use CTE
With popvsVac (Continent,Location,Date,Population,New_Vaccination,RollingPeopleVaccinated)
as
(
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(cast(CovidVaccinations.new_vaccinations as int)) OVER (Partition by CovidDeaths.location,CovidDeaths.Date) as RollingPeopleVaccinated
From  [portfolio project] ..CovidDeaths
join [portfolio project]..CovidVaccinations
  On CovidDeaths.location = CovidVaccinations.location
  and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From popvsVac

--TEMP TABLE
 Drop Table if exists #PercentPopulationVaccinated 
Create Table #percentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric)

Insert Into #percentPopulationVaccinated
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(cast(CovidVaccinations.new_vaccinations as int)) OVER (Partition by CovidDeaths.location,CovidDeaths.Date) as RollingPeopleVaccinated
From  [portfolio project] ..CovidDeaths
join [portfolio project]..CovidVaccinations
  On CovidDeaths.location = CovidVaccinations.location
  and CovidDeaths.date = CovidVaccinations.date
--where CovidDeaths.continent is not null
--order by 2,3


Select * , (RollingPeopleVaccinated/Population)*100
From #percentPopulationVaccinated



--Creating View to store data for later visualtization

Create view PercentPopulationVaccinated as
Select CovidDeaths.continent,CovidDeaths.location,CovidDeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(cast(CovidVaccinations.new_vaccinations as int)) OVER (Partition by CovidDeaths.location,CovidDeaths.Date) as RollingPeopleVaccinated
From  [portfolio project] ..CovidDeaths
join [portfolio project]..CovidVaccinations
  On CovidDeaths.location = CovidVaccinations.location
  and CovidDeaths.date = CovidVaccinations.date
--where CovidDeaths.continent is not null
--order by 2,3






