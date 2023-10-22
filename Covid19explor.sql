/*1.1.	Identifying Countries with Extreme Death Counts and Vaccination Rates: 
a. Which countries have the highest and lowest total death counts from COVID-19?
 b. Which countries have the highest and lowest vaccination rates*/
--  To create a table named 'covid_data_comp' to store the COVID-19 data 
CREATE TABLE covid_data_comp (
    country VARCHAR(255), -- Country name
    total_cases INT, -- Total confirmed COVID-19 cases
    total_deaths INT, -- Total COVID-19 deaths
    death_rate DECIMAL(5,2), -- Death rate as a percentage
    fully_vaccinated_percentage DECIMAL(5,2), -- Percentage of fully vaccinated population
    cases_comparison VARCHAR(25), -- Comparison of total cases against global average
    deaths_comparison VARCHAR(25), -- Comparison of total deaths against global average
    death_rate_comparison VARCHAR(25), -- Comparison of death rate against global average
    vaccination_comparison VARCHAR(25) -- Comparison of vaccination rate against global average
);

-- Insert data into the 'covid_data' table
INSERT INTO covid_data_comp (
    country,
    total_cases,
    total_deaths,
    death_rate,
    fully_vaccinated_percentage,
    cases_comparison,
    deaths_comparison,
    death_rate_comparison,
    vaccination_comparison
)

-- Define a CTE (Common Table Expression) named 'country_metrics' to calculate country-specific metrics
WITH country_metrics AS (
    SELECT
        d.location AS country, -- Alias 'location' column as 'country' for better readability
        MAX(d.total_cases) AS total_cases, -- Calculate maximum total cases for each country
        MAX(d.total_deaths) AS total_deaths, -- Calculate maximum total deaths for each country
        ROUND((MAX(d.total_deaths) / MAX(d.total_cases)) * 100, 2) AS death_rate, -- Calculate death rate for each country
        MAX(v.people_fully_vaccinated_per_hundred) AS fully_vaccinated_percentage -- Calculate maximum vaccination rate for each country
    FROM c_deaths AS d
    INNER JOIN c_vacc AS v
    ON d.iso_code = v.iso_code
    AND d.date = v.date
    GROUP BY d.location -- Group by country to aggregate metrics
),

-- Define another CTE named 'global_averages' to calculate global averages for each metric
global_averages AS (
    SELECT
        AVG(total_cases) AS avg_total_cases, -- Calculate average total cases globally
        AVG(total_deaths) AS avg_total_deaths, -- Calculate average total deaths globally
        AVG(death_rate) AS avg_death_rate, -- Calculate average death rate globally
        AVG(fully_vaccinated_percentage) AS avg_vaccination_rate -- Calculate average vaccination rate globally
    FROM country_metrics
)

-- Main query to compare country metrics  with global averages
SELECT
    cm.country, -- Select country name
    cm.total_cases, -- Select total cases for the country
    cm.total_deaths, -- Select total deaths for the country
    cm.death_rate, -- Select death rate for the country
    cm.fully_vaccinated_percentage, -- Select vaccination rate for the country
    -- Use CASE expressions to compare country metrics against global averages
    CASE
        WHEN cm.total_cases > ga.avg_total_cases THEN 'Above Average'
        ELSE 'Below Average'
    END AS cases_comparison,
    CASE
        WHEN cm.total_deaths > ga.avg_total_deaths THEN 'Above Average'
        ELSE 'Below Average'
    END AS deaths_comparison,
    CASE
        WHEN cm.death_rate > ga.avg_death_rate THEN 'Above Average'
        ELSE 'Below Average'
    END AS death_rate_comparison,
    CASE
        WHEN cm.fully_vaccinated_percentage > ga.avg_vaccination_rate THEN 'Above Average'
        ELSE 'Below Average'
    END AS vaccination_comparison
FROM country_metrics AS cm
CROSS JOIN global_averages AS ga -- Join country metrics with global averages
ORDER BY cm.country; -- Order results by country name-- To Create a view named 'vaccination_death_rates' 

/* 2.	Relationship between Vaccination Rates and COVID-19 Death Rates: 
How does vaccination rate correlate with COVID-19 death rates? */

-- Create a view named 'vaccination_death_rates'

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


/*3.	Impact of Lockdown Stringency on COVID-19 Spread: 
How does the stringency of government lockdown measures affect the spread of COVID-19? */

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


/*4.	Socio-economic Factors Associated with COVID-19 Death Rates:
 What are the socio-economic factors associated with higher COVID-19 death rates? */

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


/* 5.Impact of Hospital Bed Availability on COVID-19 Mortality Rates: 
How does the availability of hospital beds affect COVID-19 mortality rates? */

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

/ *6.Impact of Vaccination on COVID-19 Mortality Rates: 
How has vaccination affected COVID-19 mortality rates in different countries? */

-- To see the impact of vaccination on mortality rates (with rounded averages)

WITH vaccination_start_dates AS (
    SELECT location, MIN(date) AS vaccination_start_date
    FROM c_vacc
    WHERE people_vaccinated_per_hundred > 0
    GROUP BY location
)
SELECT c_deaths.location,
       ROUND(AVG(CASE WHEN c_deaths.date < vaccination_start_dates.vaccination_start_date
                      AND c_deaths.date >= (vaccination_start_dates.vaccination_start_date - INTERVAL '3 months')
                      THEN c_deaths.total_deaths_per_million END), 2) AS pre_vaccination_mortality,
       ROUND(AVG(CASE WHEN c_deaths.date >= vaccination_start_dates.vaccination_start_date
                      AND c_deaths.date < (vaccination_start_dates.vaccination_start_date + INTERVAL '3 months')
                      THEN c_deaths.total_deaths_per_million END), 2) AS post_vaccination_mortality,
       (ROUND(AVG(CASE WHEN c_deaths.date < vaccination_start_dates.vaccination_start_date
                      AND c_deaths.date >= (vaccination_start_dates.vaccination_start_date - INTERVAL '3 months')
                      THEN c_deaths.total_deaths_per_million END), 2) -
       ROUND(AVG(CASE WHEN c_deaths.date >= vaccination_start_dates.vaccination_start_date
                      AND c_deaths.date < (vaccination_start_dates.vaccination_start_date + INTERVAL '3 months')
                      THEN c_deaths.total_deaths_per_million END), 2)) AS mortality_reduction
FROM c_deaths
JOIN vaccination_start_dates
ON c_deaths.location = vaccination_start_dates.location
GROUP BY c_deaths.location
ORDER BY mortality_reduction DESC;

