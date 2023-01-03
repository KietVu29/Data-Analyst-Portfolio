-- Observe CovidDeaths Data
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Observe CovidVaccination Data
SELECT *
FROM PortfolioProject..CovidVaccination
ORDER BY 3,4


-- SELECT Data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Total Cases vs. Total Deaths
-- Death ratio in the U.S.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2


-- Total Cases vs. Population
-- Percentage of population who has Covid-19 in U.S.
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2


-- Countries with the highest Infection Rate compared to their population
SELECT location, population, MAX(total_cases) AS InfectionCount, 
		MAX((total_cases/population)*100) AS PopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PopulationInfectionPercentage DESC


-- Continents with the highest Death Count compared to their population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Total deaths in each country
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global Death Percentage by date
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
			(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- Total population vs. Vaccinations 
WITH PopVsVac (continent, location, date, population, new_vaccinations, TotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CAST(vac.new_vaccinations AS bigint))
	OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (TotalVaccinations/population)*100 AS VaccinationPercentage
FROM PopVsVac

-- VIEW to store data
DROP VIEW IF Exists PopVsVac

CREATE VIEW PopVsVac AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
	, SUM(CAST(vac.new_vaccinations AS bigint))
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS TotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccination vac
	ON dea.locaTion = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PopVsVac