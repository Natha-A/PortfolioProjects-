--WORKING WITH COVID DATA FROM JAN 2020 - APRIL 2021

Select * 
From CovidDeaths 
Where continent is not null
Order by 3,4;

--Select * 
--From CovidVaccinations 
--ORDER by 3,4;

--Date to be used 

Select location, date, total_cases,new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by 1,2

--Total Cases vs Total Deaths 
-- shows the likelihood of dying if you contract COVID in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as Death_Percentage
From CovidDeaths
Where continent is not null
Order by 1,2

Select location, date, total_cases,total_deaths, (total_deaths/total_cases) *100 as Death_Percentage
From CovidDeaths
Where location like '%Canada%'
Order by 1,2;

-- Total Cases Vs Population
-- Shows percentage of population got COVID
Select location, date, population,total_cases, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%Canada%'
Order by 1,2;

--Highest infect rates compared to population
Select location, population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
-- Where location like '%Canada%'
Where continent is not null
Group by location,population
Order by PercentPopulationInfected desc;

-- Countries with HighestDeathCount per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
-- the cast funtion is used to convert the data type (nvarchar) to to 'Int' of total_deaths in original data togive accurate count
From CovidDeaths
-- Where location like '%Canada%'
Where continent is not null
Group by location
Order by TotalDeathCount desc;

--BREAKDOWN BY CONTINENT
-- this command does notgive the accurate numbers by continent; e.g. North America only factors in numbers from the US and not other countries 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;

-- The below command gives more accurate numbers but also throws in some unwanted categorieslike World,European Union and International
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc;

-- from the above, let's use the 'sum' function to replace 'max' function to aggregate all new_deaths in the locations
Select continent, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;


---GLOBAL NUMBERS
--Look at daily total cases across the world;regardless of location and continent

Select  date, SUM(new_cases) as TotalDailyCases
From CovidDeaths
Where continent is not null 
Group by date
Order by 1,2;

--Daily deaths across the world; use the 'Cast' function to change data type for "new_deaths' to allow aggregation
Select  date, SUM(cast(new_deaths as int)) as TotalDailyDeaths
From CovidDeaths
Where continent is not null 
Group by date
Order by 1,2;

-- Global DeathPercentage across the world

Select  date, SUM(new_cases) as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DailyDeathPercentage
From CovidDeaths
Where continent is not null 
Group by date
Order by 1,2;

--DeathPercentage for entire period across the world
Select  SUM(new_cases) as TotalDailyCases, SUM(cast(new_deaths as int)) as TotalDailyDeaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DailyDeathPercentage
From CovidDeaths
Where continent is not null 
Order by 1,2;

Select * from CovidVaccinations

--Join deaths and vaccination tables

Select *
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date

 ---Total populatin vs vaccination across the World

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;

--Partition aggregate new-vaccinations by location (rolling counts)
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;

-- Determine how many people are vaccinated per country population:create CTE (Common Table Expression)
With PopVsVac (continent, location, date,population, new_vaccinations,RollingVaccinationCount)
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingVaccinationCount/population)*100 as RollingVaccinationPercentage
From PopVsVac

--- TEMP TABLE

Create Table #PercentPopulationVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated1
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinationCount/population)*100 
From #PercentPopulationVaccinated1

--Drop table helps to effect changes easily in the created table without deleting views or temp tables

Drop Table if exists #PercentPopulationVaccinated1
Create Table #PercentPopulationVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

Insert into #PercentPopulationVaccinated1
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingVaccinationCount/population)*100 
From #PercentPopulationVaccinated1

--Create view to store data

Create view PercentPopulationVaccinated1 as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated1


Create View RollingVaccinationCount as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location 
Order by dea.location,dea.date) as RollingVaccinationCount
From CovidDeaths dea
Join CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From RollingVaccinationCount