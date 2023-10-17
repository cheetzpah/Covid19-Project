-- To Create a view named 'vaccination_death_rates' 

CREATE VIEW vaccination_death_rates AS
SELECT c_vacc.location,
       c_vacc.date,
       c_vacc.people_vaccinated_per_hundred AS vaccination_rate, -- Percentage of population vaccinated
       c_deaths.total_deaths_per_million AS death_rate -- COVID-19 deaths per million
FROM c_vacc
JOIN c_deaths
ON c_vacc.iso_code = c_deaths.iso_code
AND c_vacc.date = c_deaths.date
ORDER BY c_vacc.location, c_vacc.date; 

--  To create a view named 'lockdown_covid_spread'

CREATE VIEW lockdown_covid_spread AS
SELECT c_vacc.location,
       c_vacc.date,
       c_vacc.stringency_index AS lockdown_stringency, -- Government lockdown measures index
       c_deaths.new_cases_smoothed_per_million AS new_cases_smoothed -- New COVID-19 cases per million (smoothed)
FROM c_vacc
JOIN c_deaths
ON c_vacc.iso_code = c_deaths.iso_code
AND c_vacc.date = c_deaths.date
ORDER BY c_vacc.location, c_vacc.date; 

-- To create a view named 'socioeconomic_death_rates'

CREATE VIEW socioeconomic_death_rates AS
SELECT c_deaths.location,
       c_deaths.date,
       c_deaths.total_deaths_per_million AS death_rate, -- COVID-19 deaths per million
       c_vacc.gdp_per_capita, -- GDP per capita
       c_vacc.extreme_poverty, -- Percentage of population in extreme poverty
       c_vacc.cardiovasc_death_rate, -- Cardiovascular death rate
       c_vacc.diabetes_prevalence -- Diabetes prevalence
FROM c_vacc
JOIN c_deaths
ON c_vacc.iso_code = c_deaths.iso_code
AND c_vacc.date = c_deaths.date
ORDER BY c_deaths.location, c_deaths.date; 

--  To create a view named 'hospital_beds_mortality'

CREATE VIEW hospital_beds_mortality AS
SELECT c_deaths.location,
       c_deaths.date,
       c_deaths.total_deaths_per_million AS mortality_rate, -- COVID-19 deaths per million
       c_vacc.hospital_beds_per_thousand AS hospital_beds -- Hospital beds per thousand people
FROM c_vacc
JOIN c_deaths
ON c_vacc.iso_code = c_deaths.iso_code
AND c_vacc.date = c_deaths.date
ORDER BY c_deaths.location, c_deaths.date; 

--  To create a view named 'older_population_mortality'

CREATE VIEW older_population_mortality AS
SELECT c_deaths.location,
       c_deaths.date,
       c_deaths.total_deaths_per_million AS mortality_rate, -- COVID-19 deaths per million
       c_vacc.aged_65_older -- Proportion of population aged 65 and over
FROM c_vacc
JOIN c_deaths
ON c_vacc.iso_code = c_deaths.iso_code
AND c_vacc.date = c_deaths.date
ORDER BY c_deaths.location, c_deaths.date; 