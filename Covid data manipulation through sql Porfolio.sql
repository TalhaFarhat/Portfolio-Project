SELECT * 
FROM PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL	
Order by 3,4
SELECT * 
FROM PortfolioProject1..[CovidVaccinations]
WHERE continent is not NULL	
Order by 3,4 

SELECT Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL
Order by 1,2

Alter Table PortfolioProject1..CovidDeaths
Alter Column total_deaths float

Alter Table PortfolioProject1..CovidDeaths
Alter Column total_cases float

--Looking at total cases vs. total deaths

SELECT Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject1..[CovidDeaths]
Order by 1,2

--Shows what percentage  of people got covid

SELECT Location, date, total_cases,population,(total_cases/population)*100 as infectionPercentage
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL	
Order by 1,2

SELECT location,population, Max(total_cases) as HighestInfectedCount,MAX((total_cases/population))*100 as infectionPercentage
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL	
Group By location,population
Order by infectionPercentage desc

--showing the countries with highest death count 
SELECT location,MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL	
Group By location
Order by TotalDeathCount desc

--showing the continents with highest death count 
SELECT continent,SUM( MAX(Cast(total_deaths as int)
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL	
Group By continent
Order by TotalDeathCount desc

--verifying the data
SELECT MAX(total_deaths)
FROM PortfolioProject1..[CovidDeaths]
WHERE location = 'Australia'

SELECT continent,MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL	
Group By continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases	, SUM(cast(new_deaths AS int)) as total_deaths--,total_deaths, population
From PortfolioProject1..[CovidDeaths]
WHERE continent is not NULL
Group by date
Order by 1,2

--combining both tables
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	Order by dea.iso_code
	
--checking vacccination percentages
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as total_vacc
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	Order by dea.location,date desc


--CTE
WITH PopVsVac (Continent , Location ,Date, Population,New_vaccinations, total_vacc)
as (
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as total_vacc
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	--Order by dea.location,date desc
	)
Select * , (total_vacc/Population)*100 as percentageVaccination
From PopVsVac
order by 2,3

DROP TABLE if exists #PercentPoplationcvaccinated
Create table #PercentPoplationcvaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vacc numeric,
)
Insert Into #PercentPoplationcvaccinated

SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as total_vacc
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	--Order by dea.location,date desc
	
Select * , (total_vacc/Population)*100 as percentageVaccination
From #PercentPoplationcvaccinated
order by 2,3

--creating view for visualization later

Create View PercentPoplationcvaccinated as
SELECT dea.continent , dea.location , dea.date , dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location order by dea.location, dea.date) as total_vacc
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
	--Order by dea.location,date desc