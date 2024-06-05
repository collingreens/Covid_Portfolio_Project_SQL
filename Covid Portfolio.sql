Select location,date,total_cases,new_cases,total_deaths,population
From CovidProject..CovidDeaths$
Order by 1,2

--Altered columns values
Alter Table CovidDeaths$
Alter Column total_deaths Float;

Alter Table CovidDeaths$
Alter Column total_cases Float;

Alter Table CovidDeaths$
Alter Column population Float;



--Looking at Total Cases VS Total Deaths

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
Order by 1,2

--Altered columns values
Alter Table CovidDeaths$
Alter Column total_deaths Float;

Alter Table CovidDeaths$
Alter Column total_cases Float;

Alter Table CovidDeaths$
Alter Column population int;

--Looking at Total Cases VS Population

Select location,date,total_cases,population,(total_cases/population)*100 as PopulationInfected
From CovidProject..CovidDeaths$
Where location like '%states%'
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
Where location like '%income%'
Group by Location,population
Order by HighestInfectionCount desc

--Showing Countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Showing Death count by Continent

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is null
Group by location
Order by TotalDeathCount desc


-- Global numbers

Select Sum(cast(new_cases as int)) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
where continent is not null
Order by 1,2


Select dea.continent, dea.location, dea.date, convert(bigint,dea.population), vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 1,2,3


-- Using a CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, convert(bigint,dea.population), vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select * , (convert(float,RollingPeopleVaccinated/Population))*100
From PopvsVac

--Temp Table

-- Droping the table if it exists
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

-- Creating the temporary table
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

-- Inserting data into the temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    convert(numeric, dea.population) as Population, 
    convert(numeric, vac.new_vaccinations) as New_vaccinations, 
    SUM(convert(numeric, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM 
    CovidProject..CovidDeaths$ dea
JOIN 
    CovidProject..CovidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

-- Selecting the data and calculate the percentage of the population vaccinated
SELECT  *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;


--Creating View to store data for later visualizations

Create View Table1 as 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is not null
Group by Location
--Order by TotalDeathCount desc
