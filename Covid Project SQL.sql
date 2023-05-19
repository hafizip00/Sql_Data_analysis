
SELECT * FROM  Portfolio.dbo.CovidDeathss
order by 3,4

--Select Data We are goin to use

Select Location  ,  date , total_cases,  new_cases, total_deaths, population  
From Portfolio..CovidDeathss
order by 1,2

--Total  Cases vs Total Deaths


Select Location  ,  date , total_cases, total_deaths, (total_deaths/total_cases)*100  as Death_Percentage
From Portfolio..CovidDeathss
Where location = 'Pakistan'
order by 1,2


--How Many People Infected

Select Location  ,  date , total_cases, population, (total_cases/population)*100  as Infected_Percentage
From Portfolio..CovidDeathss
Where location = 'Pakistan'
order by 1,2

--Highest Infection Rate

Select Location  ,  population ,Max(total_cases) as total_cases, Max((total_cases/population))*100  as Highest_Infected_Percentage
From Portfolio..CovidDeathss
group by  location  , population
order by Highest_Infected_Percentage desc


-- Showing Highest Death Count per  Population

Select Location  ,  Max(cast(total_deaths as int)) as Total_Deaths
From Portfolio..CovidDeathss
where continent is not null
group by  location
order by Total_Deaths desc

-- Deaths by Continent

Select location  ,  Max(cast(total_deaths as int)) as Total_Deaths
From Portfolio..CovidDeathss
where continent is null
group by  location
order by Total_Deaths desc


Select continent  ,  Max(cast(total_deaths as int)) as Total_Deaths
From Portfolio..CovidDeathss
where continent is not null
group by continent
order by Total_Deaths desc

--Global Numbers

Select  date , Sum(new_cases) as total_cases ,
Sum(cast(new_deaths as int)) as Total_deaths ,
(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Total_death_percent
from Portfolio..CovidDeathss
where  continent  is not null
Group by  date
order  by  1,2

Select  Sum(new_cases) as total_cases ,
Sum(cast(new_deaths as int)) as Total_deaths ,
(Sum(cast(new_deaths as int))/Sum(new_cases))*100 as Total_death_percent
from Portfolio..CovidDeathss
where  continent  is not null
--Group by  date
order  by  1,2


-- Vaccinations 

Select  dea.continent  , dea.location , dea.date  ,  dea.population , vac.new_vaccinations
from  Portfolio..CovidDeathss as dea join
Portfolio..Vaccinations vac
on dea.date = vac.date  and dea.location = vac.location
where dea.continent is not null
order  by  2,3


Select  dea.continent  , dea.location , dea.date  ,  dea.population , vac.new_vaccinations , SUM(Convert(int , vac.new_vaccinations))
OVER  (Partition by dea.location order  by dea.date) as Rolling_vacc
from  Portfolio..CovidDeathss as dea join
Portfolio..Vaccinations vac
on dea.date = vac.date  and dea.location = vac.location
where dea.continent is not null
order   by  2,3

--Using CTE's CTE's 

With PopvsVac ( Continent , Location , Date  ,  Population  , New_vaccinations , Rolling_vacc)
as
(
Select  dea.continent  , dea.location , dea.date  ,  dea.population , vac.new_vaccinations , SUM(Convert(int , vac.new_vaccinations))
OVER  (Partition by dea.location order  by dea.date) as Rolling_vacc
from  Portfolio..CovidDeathss as dea join
Portfolio..Vaccinations vac
on dea.date = vac.date  and dea.location = vac.location
where dea.continent is not null
--order   by  2,3
)

Select * , (Rolling_vacc/Population)*100 as Vaccination_percentage from PopvsVac;


--Using Temp Table
Drop Table if exists #Percent_population_vaccinated

Create Table #Percent_population_vaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rolling_people_Vaccinated  numeric,
)


Insert into #Percent_population_vaccinated 
Select  dea.continent  , dea.location , dea.date  ,  dea.population , vac.new_vaccinations , SUM(Convert(int , vac.new_vaccinations))
OVER  (Partition by dea.location order  by dea.date) as Rolling_vacc
from  Portfolio..CovidDeathss as dea join
Portfolio..Vaccinations vac
on dea.date = vac.date  and dea.location = vac.location
where dea.continent is not null


Select * , (Rolling_people_Vaccinated/Population)*100 as Vaccination_percentage from #Percent_population_vaccinated;


-- Create View for data visualization for later use

Create View Percent_population_vaccinatedView as
Select  dea.continent  , dea.location , dea.date  ,  dea.population , vac.new_vaccinations , SUM(Convert(int , vac.new_vaccinations))
OVER  (Partition by dea.location order  by dea.date) as Rolling_vacc
from  Portfolio..CovidDeathss as dea join
Portfolio..Vaccinations vac
on dea.date = vac.date  and dea.location = vac.location
where dea.continent is not null
--order   by  2,3


Select *  from  Percent_population_vaccinatedView