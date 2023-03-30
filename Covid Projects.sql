use portfolioproject

select * from CovidDeaths
where continent is not null
order by 3,4

select * from CovidVaccinations
order by 3,4

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is null
order by 1,2

-- looking at total cases vs total_deaths
-- shows likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 deathprecentage
from CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

-- looking at total cases vs population
-- shows what precentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 percentpopulationinfected
from CovidDeaths
-- where location like '%states%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, max(total_cases) highestinfenctioncoun, 
max((total_cases/population))*100 percentpopulationinfected
from CovidDeaths
-- where location like '%states%'
group by location, population
order by 4 desc

-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
-- where location like '%states%'
where continent is not null
group by location
order by 2 desc

-- lets break things down by continent
select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by 2 desc

-- showing contintents with the highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
-- where location like '%states%'
where continent is not null
group by continent
order by 2 desc

-- global numbers
select sum(new_cases)totalcases, sum(cast(new_deaths as int)) totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 deathprecentage
from CovidDeaths
--where location like '%states%'
where continent is not null
-- group by date
order by 1,2

-- Looking at total population vs vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location,
cd.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
from CovidDeaths cd
join CovidVaccinations cv on
cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- USE CTE
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location,
	cd.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
from CovidDeaths cd
join CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
-- order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 
from popvsvac

-- temp table
drop table if exists #precentpopulationvaccinated
create table #precentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #precentpopulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location,
	cd.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
from CovidDeaths cd
join CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
-- where cd.continent is not null
-- order by 2,3

select *, (rollingpeoplevaccinated/population)*100 
from #precentpopulationvaccinated

-- creating view to store data for later visualizations
create view precentpopulationvaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location,
	cd.date) as rollingpeoplevaccinated 
--,(rollingpeoplevaccinated/population)*100
from CovidDeaths cd
join CovidVaccinations cv 
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
-- order by 2,3

select * from precentpopulationvaccinated
