Select *
from PROJECT..CovidDeaths
order by 3,4

Select *
from PROJECT..Covidvaccination
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PROJECT..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, ((cast (total_deaths as int)/total_cases))*100 as DeathPercentage
from PROJECT..CovidDeaths
where location like '%state%'
order by 1,2


--Lookinh at Total cases vs The Population
--Shows what percentage of people got covid

Select Location, date, population, total_cases, total_deaths, (total_cases/population)*100 as PercentOfPopulationGotInfected
from PROJECT..CovidDeaths
where location like '%state%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentOfPopulationGotInfected
from PROJECT..CovidDeaths
Group by Location, Population
order by PercentOfPopulationGotInfected desc


--Countries with Highest Death Count Per Population


Select Location, MAX(cast(total_deaths as int)) as TotalDeathcount
from PROJECT..CovidDeaths
Group by Location
order by TotalDeathcount desc


----Continent with Highest Death Count Per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
from PROJECT..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathcount desc


-- Global Numbers

Select date, total_cases, total_deaths, ((cast(total_deaths as int)/total_cases))*100 as DeathPercentage
from PROJECT..CovidDeaths
where continent is not null
order by 1,2


select sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage  
from PROJECT..CovidDeaths
--group by date
order by 1,2


--Total population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(CONVERT(bigint, vac.new_vaccinations)) over (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PROJECT..CovidDeaths dea
join PROJECT..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PROJECT..CovidDeaths dea
join PROJECT..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/ population)*100
from PopvsVac


--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PROJECT..CovidDeaths dea
join PROJECT..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date

select *, (RollingPeopleVaccinated/ population)*100
from #PercentPopulationVaccinated



--Creating View to store data for Vizualization


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, Vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PROJECT..CovidDeaths dea
join PROJECT..Covidvaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null