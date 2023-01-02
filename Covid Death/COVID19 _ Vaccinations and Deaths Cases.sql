Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccination
order by 3,4

-- Select Data to be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs. Total Deaths
-- Death ratio in the U.S.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

-- Total Cases vs. Population
-- Percentage of population who has Covid-19 in U.S.
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location = 'United States'
order by 1,2

-- Countries with the highest Infection Rate compared to their population
Select location, population, MAX(total_cases) as InfectionCount, 
		MAX((total_cases/population)*100) as PopulationInfectionPercentage
From PortfolioProject..CovidDeaths
Group by population, location
order by PopulationInfectionPercentage desc

-- Continents with the highest Death Count compared to their population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not  null
Group by continent
order by TotalDeathCount desc

-- Countries with the highest Death Count compared to their population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Global Death Percentage by date
Select date, Sum(new_cases) as TotalCases, Sum(cast(new_deaths as int)) as totalDeaths, 
			(sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by date

-- Total population vs. Vaccinations 
With PopVsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CAST(vac.new_vaccinations as bigint))
	OVER (Partition by dea.location ORDER by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)

Select *, (TotalVaccinations/population)*100 as VaccinationPercentage
From PopVsVac

-- View to store data
Create View PopVsVac as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CAST(vac.new_vaccinations as bigint))
	OVER (Partition by dea.location ORDER by dea.location, dea.date) as TotalVaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
	On dea.locatsion = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PopVsVac