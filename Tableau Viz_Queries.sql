--QUERIES FOR TABLEAU VISUALIZATION
--Slight differences in the numbers for query 1 and 1B.
--1. TotalDeath Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--1B
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
Where location = 'World'
--Where continent is not null 
Order by 1,2

--2. Looking at DeathCounts by Continents 
--2A
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
--2B
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount 
From CovidDeaths
Where continent is null 
-- and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc


--3. PercentPopulationInfected
--3A: All locations as in data source
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--3B:Excludes data from continent aggregates in location
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location is not null 
and location not in ('Africa','Asia', 'Europe','European Union','North America','Oceania', 'South America','International','World')
Group by location, Population 
Order by PercentPopulationInfected desc

--4. PercentPopulationInfected by date
--4A: All data from source 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

--4B:Exclude aggregate continent data in location
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where location is not null 
and location not in ('Africa','Asia', 'Europe','European Union','North America','Oceania', 'South America','International','World')
Group by Location, Population, date
order by PercentPopulationInfected desc
