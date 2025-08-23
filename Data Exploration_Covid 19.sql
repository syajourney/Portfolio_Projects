
SELECT *
FROM CovidDeaths


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY location, date



--Total Cases vs Total Deaths in Malaysia

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 death_percentage
FROM CovidDeaths
WHERE location like 'mal%sia'
ORDER BY location, date



--Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 infected_percentage
FROM CovidDeaths
WHERE location like 'mal%sia'
ORDER BY location, date



--Highest Infection Rate vs Population in Countries

SELECT location, population, MAX(total_cases) highest_infection_cases, MAX((total_cases/population))*100 infection_percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_percentage desc



--Highest Death Count vs Population in Countries

SELECT location, MAX(CAST(total_deaths as int)) highest_death_count
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY highest_death_count desc



--Percentage of deaths per day globally

SELECT date, 
SUM(new_cases) daily_cases, 
SUM(CAST(new_deaths AS int)) daily_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 percentage_daily_death
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY date



SELECT *
FROM CovidVaccinations vac
JOIN CovidDeaths dth
	ON vac.location = dth.location
	and vac.date = dth.date



--Total Population Vaccinated Daily in Countries

SELECT vac.location, vac.date, dth.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by vac.location Order by vac.date) people_vaccinated
FROM CovidVaccinations vac
JOIN CovidDeaths dth
	ON vac.location = dth.location
	and vac.date = dth.date
WHERE dth.continent is not null
ORDER BY 1,2



--Percentage People Vaccinated vs Population

With vaccinated_percentage (location, population, people_vaccinated)
as
(
SELECT vac.location, dth.population, SUM(CONVERT(int,vac.new_vaccinations)) people_vaccinated
FROM CovidVaccinations vac
JOIN CovidDeaths dth
	ON vac.location = dth.location
	and vac.date = dth.date
WHERE dth.continent is not null
GROUP BY vac.location, dth.population
)
SELECT *, (people_vaccinated/population)*100
FROM vaccinated_percentage
ORDER BY location




