Select *
FROM PortfolioProject..coviddeaths
where continent is not null
order by 3,4

--Select *
--FROM PortfolioProject..covidvaccinations
--order by 3,4

-- Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeaths
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- (conver(decimal,...) is used here due to the "Operand data type nvarchar is invalid for divide operator." issue! decimal = for an exact number! CAST() is also good here!
-- Shows the likelihood of death from COVID-19 in certain countries.
SELECT Location, date, total_cases,total_deaths, (convert(decimal,total_deaths)/ convert(decimal,total_cases))*100
from PortfolioProject..coviddeaths
where location like '%united%'
and continent is not null
order by 1,2 


-- Looking at the total cases vs the population
-- shows the percentage of people with covid in a country
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationCOVID
from PortfolioProject..coviddeaths
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at countries with the highest infections rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopultaionInfected    
from PortfolioProject..coviddeaths
where location like '%states%'
and continent is not null
group by population, location
order by PercentPopultaionInfected desc

-- NOW COUNTRIES DEATH COUNT
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
Where continent is not null
group by location
order by TotalDeathCount desc


-- LETS LOOK AT THE CONTINENT BREAKDOWN AND THEIR DEATH COUNT
select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..coviddeaths
Where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers
-- Global death percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) * 100 as GlobalDeathPercentage
from PortfolioProject..coviddeaths
where continent is not null
-- group by date
order by 1,2


-- COVID VACCINATIONS PORTION:

-- looking at total populations vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date)-- CAST OR CONVERT BOTH OKAY!
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null   -- adding "is not null" here gets rid of the portions of data mentioning "income"!
order by 2,3	

-- USE CTE

with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date)-- CAST OR CONVERT BOTH OKAY!
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null   -- adding "is not null" here gets rid of the portions of data mentioning "income"!
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac 

-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date)-- CAST OR CONVERT BOTH OKAY!
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null   -- adding "is not null" here gets rid of the portions of data mentioning "income"!
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated 


-- Creating view to store data for later data viz

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order By dea.location, dea.date)-- CAST OR CONVERT BOTH OKAY!
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null   -- adding "is not null" here gets rid of the portions of data mentioning "income"!
--order by 2,3

-- now the view has been created it is a permanent table ready to be used.

Select *
from PercentPopulationVaccinated