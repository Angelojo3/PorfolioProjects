select *
from PorfolioProject..CovidDeaths
Where continent is not null
order by 3,4

select *
from PorfolioProject..CovidVaccinations
order by 3,4

-- Selecting the data that I m going to be using

select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths
order by 1,2

--Now let's look at the total cases vs population

select Location, date, total_cases, population, (total_cases/population)*100 as Percentofpopulation
From PorfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- let's look at countries with highest  Infection Rate compared to population

select Location, population, max(total_cases)as highestInfectionCount, Max((total_cases/population))*100 as PercentofpopulationInfected
From PorfolioProject..CovidDeaths
Where continent is not null
group by location, population
order by PercentofpopulationInfected desc


--Countries with the Highest Death count per Population

select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

--Let's break it down by continents

-- Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PorfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table


Drop Table if exists #PercentpopulationVaccinated
Create table #PercentpopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentpopulationVaccinated



-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths dea
join PorfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3