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

-- Main query to compare country metrics against global averages
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
ORDER BY cm.country; -- Order results by country name


