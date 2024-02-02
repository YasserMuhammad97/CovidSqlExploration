/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

 

-- Select Data that we are going to be starting with

 select * from PortfolioProject..CovidDeaths$
 select * from PortfolioProject..CovidVaccinations$

 select Location,date,total_cases,new_cases,total_deaths,population
 from PortfolioProject..CovidDeaths$
 order by 1 ,2 ;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
 select date, location,    (total_deaths/total_cases)*100 as [DeathPercentage] , total_deaths , total_cases
 from PortfolioProject..CovidDeaths$
  where iso_code = 'EGY'
  order by 1;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
 select date, location,    (total_cases/population)*100.0 as [percentage of people with covid]
 from PortfolioProject..CovidDeaths$
  where iso_code = 'USA' 

   order by 1 ;


-- Countries with Highest Infection Rate compared to Population
  select location,max(total_cases) as highest_cases ,  max((total_cases/population)*100) as [infection_Rate] from PortfolioProject..CovidDeaths$
 where continent is not null

 group by location

  order by infection_Rate desc 
  
  
 

-- Countries with Highest Death Count  
select location, max(cast(total_deaths as int) ) as Hightest_Death , max( (total_deaths/population)*100 ) DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null

group by location
order by Hightest_Death desc
 

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
 select location, max(cast(total_deaths as int) ) as Hightest_Death , max( (total_deaths/population)*100 ) DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is   null
group by location
order by Hightest_Death desc
 


-- GLOBAL NUMBERS
 select date , sum(new_cases) Total_cases_Aday, sum(cast(new_deaths as int )) as total_death_Aday , (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
 from PortfolioProject..CovidDeaths$ 
where continent is not  null
 group by date
 order by date;




-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
	  select   dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(int, vac.new_vaccinations)) over	(partition by dea.location order by dea.location,dea.date) SumVaccinedPerCountryPerDay
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac	
  on dea.location = vac.location
  and dea.date = vac.date
    where dea.continent is not null  

 

-- Using CTE to perform Calculation on Partition By in previous query
	with CTE_Vacc (Continent, Location, Date, Population, New_Vaccinations, SumVaccinedPerCountryPerDay) as (
	  	  select   dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(int, vac.new_vaccinations)) over	(partition by dea.location order by dea.location,dea.date) SumVaccinedPerCountryPerDay
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac	
  on dea.location = vac.location
  and dea.date = vac.date
    where dea.continent is not null  

	)
	select * ,(SumVaccinedPerCountryPerDay/population)*100 vaccinationsPerPopulation from CTE_Vacc
	where location like '%states%'
 
 

-- Using Temp Table to perform Calculation on Partition By in previous query
	drop table if exists #PercentPopVaccinated
	create table #PercentPopVaccinated (Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric,
	New_Vaccinations numeric, SumVaccinedPerCountryPerDay numeric)  

	insert into #PercentPopVaccinated 
	select   dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(int, vac.new_vaccinations)) over	(partition by dea.location order by dea.location,dea.date) SumVaccinedPerCountryPerDay
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac	
  on dea.location = vac.location
  and dea.date = vac.date
    where dea.continent is not null  

 
	select * ,(SumVaccinedPerCountryPerDay/population)*100 vaccinationsPerPopulation from #PercentPopVaccinated
	where location like '%states%'
 
 

-- Creating View to store data for later visualizations

 Create View PercetPopVacc as
 	select   dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
  ,sum(convert(int, vac.new_vaccinations)) over	(partition by dea.location order by dea.location,dea.date) SumVaccinedPerCountryPerDay
  from PortfolioProject..CovidDeaths$ dea
  join PortfolioProject..CovidVaccinations$ vac	
	on dea.location = vac.location
	 and dea.date = vac.date
  where dea.continent is not null

	