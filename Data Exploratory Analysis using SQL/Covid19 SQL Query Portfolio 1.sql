select *
from PortfolioProject..covidDeaths
where location like 'South Africa'


--select *
--from PortfolioProject..covidVaccinations
--order by 3, 4
-- shows the likelihood of dying from covid19 in your country
Select location,date, total_cases, total_deaths, (total_deaths / total_cases)* 100 as Death_Percentage
from PortfolioProject..covidDeaths
where location like 'South Africa'


-- looking at total cases vs population
Select location,date,population, total_cases,  (total_cases / population)* 100 as Affected_Percentage
from PortfolioProject..covidDeaths
where location like 'South Africa'
order by 1, 2
--4
-- looking for countries with highest infection rate compared to population
Select location,population,date, max( total_cases) as Highest_infection_count,  max((total_cases / population)* 100) as PeopleInfected_Percentage
from PortfolioProject..covidDeaths
--where location like 'South Africa'
group by location, population, date
order by 4 desc

--3
-- Showing countries with highest death count per population
Select location,population,date, max( total_cases) as Highest_infection_count,  max((total_deaths / population)* 100) as DeathPercenatage_Per_Population
from PortfolioProject..covidDeaths
--where location like 'South Africa'
group by location, population, date
order by 5 desc

-- Showing country with highest death
Select location, max( cast(total_deaths as int)) as Total_death_count
from PortfolioProject..covidDeaths
--where location like 'South Africa'
where continent is not null
group by location
order by 2 desc

-- Let's break things down by continent
Select continent, max( cast(total_deaths as int)) as Total_death_count
from PortfolioProject..covidDeaths
--where location like 'South Africa'
where continent is not null
group by continent
order by 2 desc

--2
-- Other continents missing like canada not included in north america
Select location, max( cast(total_deaths as int)) as Total_death_count
from PortfolioProject..covidDeaths
--where location like 'South Africa'
where continent is  null
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income','International','European Union')
group by location
order by 2 desc

--Global Numbers by date
Select  date, sum(new_cases) as TotalNewCases, Sum( cast(total_deaths as int)) as Total_death_count, (sum(cast(total_deaths as int))/ sum(new_cases))*100 as DeathPercentage
from PortfolioProject..covidDeaths
--where location like 'South Africa'
where continent is  not null
group by date
order by 1, 2

--1
--Global numbers without date
select sum(new_cases) as Total_cases,Sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as bigint))/ sum(new_cases))*100 as DeathPercentage
from PortfolioProject..covidDeaths
--where location like 'South Africa'
where continent is  not null

--group by date
order by 2 desc

select *
from PortfolioProject..covidVaccinations

--Joing the 2 tables
select *
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at Total Population vs Vaccinations

-- use cte
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
 join PortfolioProject..covidVaccinations vac 
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null

)
select * , (RollingPeopleVaccinated / population)*100
from PopvsVac

--temp table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated


select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
 join PortfolioProject..covidVaccinations vac 
     on dea.location = vac.location
     and dea.date = vac.date


select * , (RollingPeopleVaccinated / population)*100
from #PercentPopulationVaccinated

-- Create view to store data for later visualizations
create view PercentPopulationVaccinated 
as

select dea.continent, dea.location, dea.date, dea.population,  vac.new_vaccinations,
Sum (convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..covidDeaths dea
 join PortfolioProject..covidVaccinations vac 
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated


-- create another view about country with highhest death
create view  CountryWithHigestDeath as
Select location, max( cast(total_deaths as int)) as Total_death_count
from PortfolioProject..covidDeaths
--where location like 'South Africa'
where continent is not null
group by location
--order by 2 desc

-- create another view  for Showing countries with highest death count per population
create view CountriesHighestDeathCount as
Select location,population, max( total_cases) as Highest_infection_count,  max((total_deaths / population)* 100) as HighestDeath_Percentage
from PortfolioProject..covidDeaths
--where location like 'South Africa'
group by location, population
--order by 4 desc
