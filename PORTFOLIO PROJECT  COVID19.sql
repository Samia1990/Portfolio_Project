/* PORTFOLIO PROJECT _COVID19 Data Exploration

Skills used : Basic SQL Concepts (USE, SELECT, FROM, WHERE, ORDER BY, LIMIT)
              SQL Queries,
              Aggregate functions,
              Group by & Having clause,
              Different operators (e.g. comparison, logical, LIKE, REGEXP, IS NULL),
              Joins (INNER, LEFT, RIGHT, OUTER),
              Window functions
              CTE Table (WITH clause),
              Creating views
             
*/


Create database Portfolio_Project_COVID19;
Drop database Portfolio_Project;
use Portfolio_Project_COVID19;
Drop table covid_deaths;

-------------------------------------------------------------------------------------------------------------------------
-- select every columns and rows from the specific table


select * 
from covid_deaths;

--------------------------------------------------------------------------------------------------------------------------
-- select specific data from the table


select location,date,population,total_cases, new_cases,total_deaths
from covid_deaths
order by 1,2;

--------------------------------------------------------------------------------------------------------------------------
-- Total cases vs total_deaths 
-- Shows likelihood of dying in a specific location


select location,date,population,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
where location like '%ger%'
order by 1,2
limit 2;

---------------------------------------------------------------------------------------------------------------------------
-- Total cases vs population
-- Shows what percentage of population infected with Covid


select location,date,population,total_cases, (total_cases/population)*100 as Infected_population_percentage
from covid_deaths
where location like '%ger%'
order by 1,2;

---------------------------------------------------------------------------------------------------------------------------
-- Countries where higher infection rate compared to population


select location,population, MAX(total_cases) as higher_infection_count, (MAX(total_cases)/population)*100 as higher_infection_rate
from covid_deaths
group by location
having population > 20000
order by higher_infection_rate desc;

---------------------------------------------------------------------------------------------------------------------------
-- Countries where lower infection rate compared to population


select location,population, MIN(total_cases) as lower_infection_count, (MIN(total_cases)/population)*100 as lower_infection_rate
from covid_deaths
group by location
having lower_infection_rate <> 0
order by lower_infection_rate desc;

---------------------------------------------------------------------------------------------------------------------------
-- Showing continents of higher death count per population


select continent,location,population, MAX(total_deaths) as higher_death_count
from covid_deaths
group by continent
having continent REGEXP '[a-z]'
order by higher_death_count desc;

---------------------------------------------------------------------------------------------------------------------------
-- Total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
	   SUM(cv.new_vaccinations) over (partition by location order by cd.location, cd.date) as rolling_people_vaccinated
from covid_deaths cd 
join covid_vaccinations cv
on cd. location = cv. location and cd.date =cv.date
order by 2,3;

---------------------------------------------------------------------------------------------------------------------------
-- Using CTE to perform Calculation on Partition By in previous query

with pop_vs_vac ( continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
as
(select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
	   SUM(cv.new_vaccinations) over (partition by location order by cd.location, cd.date) as rolling_people_vaccinated
from covid_deaths cd 
join covid_vaccinations cv
on cd. location = cv. location and cd.date =cv.date
)
select *, (rolling_people_vaccinated/population)*100 as percentage_population_having_vaccine
from pop_vs_vac;

---------------------------------------------------------------------------------------------------------------------------
-- Creating View to store data for later visualizations


create view pop_vs_vac as
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
	   SUM(cv.new_vaccinations) over (partition by location order by cd.location, cd.date) as rolling_people_vaccinated
from covid_deaths cd 
join covid_vaccinations cv
on cd. location = cv. location and cd.date =cv.date






