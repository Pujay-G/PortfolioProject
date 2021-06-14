select location, date, total_cases ,new_cases, total_deaths, population 
from testdb.CovidDeaths;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentDeaths
From testdb.CovidDeaths
Where location = "United States";

-- Looking at Total Cases vs Population
-- Shows percentage of populations got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS CasePerPopulation
From testdb.CovidDeaths
Where location = "Mongolia";

-- Looking at Countries with Highest Case Rate compared to Population
Select location, MAX(total_cases) AS HighestCaseCount, Max((total_cases/population))*100 AS CasePerPop
From testdb.CovidDeaths
Group By location, population
Order By CasePerPop Desc;

-- Looking at Countries with Highest Death Rate compated to Population
Select location, Max(CAST(total_deaths AS UNSIGNED)) AS HighestDeathCount
From testdb.CovidDeaths
Where continent != ""
Group By location
Order By HighestDeathCount Desc; 

-- Looking at Continents with the highest death per population
Select continent, Max(Cast(total_deaths as unsigned)) as TotalDeathCount
From testdb.CovidDeaths
Where continent != ""
Group by continent
Order by TotalDeathCount Desc;

-- Global numbers
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 AS DeathPercentage
From testdb.Coviddeaths
Where continent != ""
Group by date
order by STR_TO_DATE(date, "%m/%e/%y");

 Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as Death_prc
 From testdb.CovidDeaths
 Where continent != "";
 
 Select *
 From testdb.covidvaccine;
 
 -- Looking at Total Population vs Vaccinations
 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
From testdb.CovidDeaths as cd
Join testdb.covidvaccine as cv
	On cd.location = cv.location
    And cd.date = cv.date
Where cd.continent != ""
Order by cv.location, STR_TO_DATE(cv.date, "%m/%e/%y");

-- Looking at Total Vaccinations (rolling total)

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) Over (Partition by cd.location 
    Order by cd.location, STR_TO_DATE(cv.date, "%m/%e/%y")) as RollingTotalVac
From testdb.CovidDeaths as cd
Join testdb.covidvaccine as cv
	On cd.location = cv.location
    And cd.date = cv.date
Where cd.continent != ""
Order by cv.location, STR_TO_DATE(cv.date, "%m/%e/%y");
 
 -- Looking at Total Population vs Vaccinations (rolling total) with CTE
 
 With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVac)
 as
 (Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(cv.new_vaccinations) Over (Partition by cd.location 
    Order by cd.location, STR_TO_DATE(cv.date, "%m/%e/%y")) as RollingTotalVac
From testdb.CovidDeaths as cd
Join testdb.covidvaccine as cv
	On cd.location = cv.location
    And cd.date = cv.date
Where cd.continent != ""
 )
Select *, (RollingTotalVac/Population)*100 as VacPrc
From PopVsVac;


-- Creating View to store data for future visualization

Create View PercentPopulationVaccinated as 
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(cv.new_vaccinations) Over (Partition by cd.location Order by cd.location, 
    STR_TO_DATE(cv.date, "%m/%e/%y")) as RollingTotalVac
From testdb.CovidDeaths as cd
Join testdb.covidvaccine as cv
	ON cd.location = cv.location
    AND cd.date = cv.date
Where cd.continent != ""

