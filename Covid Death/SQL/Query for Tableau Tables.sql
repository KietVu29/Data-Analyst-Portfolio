-- Observe CovidDeaths Data
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Observe CovidVaccination Data
SELECT *
FROM PortfolioProject..CovidVaccination
ORDER BY 3,4


-- Table 1: Global Death Percentage
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, 
			(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Table 2: Total deaths in each country
SELECT location, SUM(cast(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS not NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC


--Table 3: Total deaths in each continent
SELECT location, SUM(cast(new_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'Low income'
					, 'High income', 'Upper middle income', 'Lower middle income') -- European Union is part of Europe
GROUP BY location	
ORDER BY TotalDeathCount DESC


-- Table 4: Countries with the highest Infection Rate compared to their population
SELECT location, population, MAX(total_cases) AS InfectionCount, 
		MAX((total_cases/population)*100) AS PopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PopulationInfectionPercentage DESC


-- Table 5: Countries with the highest Daily Infection Rate compared to their population
SELECT location, population, date, MAX(total_cases) AS InfectionCount, 
		MAX((total_cases/population)*100) AS PopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY population, location, date
ORDER BY PopulationInfectionPercentage DESC
