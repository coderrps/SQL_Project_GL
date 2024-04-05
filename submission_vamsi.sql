/*

-----------------------------------------------------------------------------------------------------------------------------------
                                               Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the additional project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CRIME
-- [Q1] Which was the most frequent crime committed each week? 
-- Hint: Use a subquery and the windows function to find out the number of crimes reported each week and assign a rank. 
Then find the highest crime committed each week

Note: For reference, refer to question number 3 - mls_week-2_gl-beats_solution.sql. 
      You'll get an overview of how to use subquery and windows function from this question */

WITH weekly_crime_counts AS (
    SELECT week_number, crime_type, COUNT(*) AS crime_count,
           RANK() OVER(PARTITION BY week_number ORDER BY COUNT(*) DESC) AS crime_rank
    FROM report_t
    GROUP BY week_number, crime_type
)
SELECT week_number, crime_type, crime_count
FROM weekly_crime_counts
WHERE crime_rank = 1;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q2] Is crime more prevalent in areas with a higher population density, fewer police personnel, and a larger precinct area? 
-- Hint: Add the population density, count the total areas, total officers and cases reported in each precinct code and check the trend*/

SELECT area_name, population_density, COUNT(*) AS crime_count
FROM location_t
JOIN report_t ON location_t.area_code = report_t.area_code
GROUP BY area_name, population_density
ORDER BY crime_count DESC;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q3] At what points of the day is the crime rate at its peak? Group this by the type of crime.
-- Hint: 
time day parts
[1] 00:00 to 05:00 = Midnight, 
[2] 05:01 to 12:00 = Morning, 
[3] 12:01 to 18:00 = Afternoon,
[4] 18:01 to 21:00 = Evening, 
[5] 21:00 to 24:00 = Night

Use a subquery, windows function to find the number of crimes reported each week and assign the rank.
Then find out at what points of the day the crime rate is at its peak.
 
 Note: For reference, refer to question number 3 - mls_week-2_gl-beats_solution.sql. 
      You'll get an overview of how to use subquery, windows function from this question */
      
WITH time_day_parts AS (
    SELECT 
        incident_time,
        CASE 
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 0 AND 4 THEN 'Midnight'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 5 AND 12 THEN 'Morning'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 13 AND 18 THEN 'Afternoon'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 19 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_day_part,
        crime_type
    FROM 
        report_t
)
SELECT 
    time_day_part,
    crime_type,
    COUNT(*) AS crime_count
FROM 
    time_day_parts
GROUP BY 
    time_day_part,
    crime_type;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q4] At what point in the day do more crimes occur in a different locality?
-- Hint: 
time day parts
[1] 00:00 to 05:00 = Midnight, 
[2] 05:01 to 12:00 = Morning, 
[3] 12:01 to 18:00 = Afternoon,
[4] 18:01 to 21:00 = Evening, 
[5] 21:00 to 24:00 = Night

Use a subquery and the windows function to find the number of crimes reported in each area and assign the rank.
Then find out at what point in the day more crimes occur in a different locality.
 
 Note: For reference, refer to question number 3 - mls_week-2_gl-beats_solution.sql. 
      You'll get an overview of how to use subquery, windows function from this question */

WITH area_time_parts AS (
    SELECT 
        location_t.area_name,
        incident_time,
        CASE 
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 0 AND 4 THEN 'Midnight'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 5 AND 12 THEN 'Morning'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 13 AND 18 THEN 'Afternoon'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 19 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_day_part
    FROM 
        report_t
    JOIN 
        location_t ON report_t.area_code = location_t.area_code
)
SELECT 
    area_name,
    time_day_part,
    COUNT(*) AS crime_count
FROM 
    area_time_parts
GROUP BY 
    area_name,
    time_day_part;
    
-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q5] Which age group of people is more likely to fall victim to crimes at certain points in the day?
-- Hint: Age 0 to 12 kids, 13 to 23 teenage, 24 to 35 Middle age, 36 to 55 Adults, 56 to 120 old.*/

WITH age_groups AS (
    SELECT 
        victim_age,
        CASE 
            WHEN victim_age BETWEEN 0 AND 12 THEN 'Kids'
            WHEN victim_age BETWEEN 13 AND 23 THEN 'Teenage'
            WHEN victim_age BETWEEN 24 AND 35 THEN 'Middle Age'
            WHEN victim_age BETWEEN 36 AND 55 THEN 'Adults'
            ELSE 'Old'
        END AS age_group,
        incident_time
    FROM 
        report_t
    JOIN 
        victim_t ON report_t.victim_code = victim_t.victim_code
),
time_day_parts AS (
    SELECT 
        incident_time,
        CASE 
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 0 AND 4 THEN 'Midnight'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 5 AND 12 THEN 'Morning'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 13 AND 18 THEN 'Afternoon'
            WHEN CAST(SUBSTRING(incident_time, 1, 2) AS UNSIGNED) BETWEEN 19 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS time_day_part,
        age_group
    FROM 
        age_groups
)
SELECT 
    time_day_part,
    age_group,
    COUNT(*) AS victim_count
FROM 
    time_day_parts
GROUP BY 
    time_day_part,
    age_group
ORDER BY 
    time_day_part,
    FIELD(age_group, 'Kids', 'Teenage', 'Middle Age', 'Adults', 'Old');

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q6] What is the status of reported crimes?.
-- Hint: Count the number of crimes for different case statuses. */

SELECT case_status_desc, COUNT(*) AS status_count
FROM report_t
GROUP BY case_status_desc;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q7] Does the existence of CCTV cameras deter crimes from happening?
-- Hint: Check if there is a correlation between the number of CCTVs in each area and the crime rate.*/
	
SELECT
    CASE
        WHEN crime_data.cctv_count > 0 THEN 'With CCTV'
        ELSE 'Without CCTV'
    END AS cctv_status,
    location_t.area_name,
    COUNT(*) AS area_count,
    AVG(crime_rate) AS avg_crime_rate
FROM (
    SELECT
        location_t.area_code,
        COUNT(DISTINCT report_t.report_no) AS crime_count,
        location_t.cctv_count,
        COUNT(DISTINCT report_t.report_no) / location_t.cctv_count AS crime_rate
    FROM
        location_t
    LEFT JOIN
        report_t ON location_t.area_code = report_t.area_code
    GROUP BY
        location_t.area_code
) AS crime_data
JOIN
    location_t ON crime_data.area_code = location_t.area_code
GROUP BY
    cctv_status,
    area_name;     

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q8] How much footage has been recovered from the CCTV at the crime scene?
-- Hint: Use the case when function, add separately when cctv_flag is true and false and check whether in particular area how many cctv is there,
How much CCTV footage is available? How much CCTV footage is not available? */

SELECT
    SUM(CASE WHEN cctv_flag = 'true' THEN location_t.cctv_count ELSE 0 END) AS footage_recovered,
    SUM(CASE WHEN cctv_flag = 'false' THEN location_t.cctv_count ELSE 0 END) AS footage_not_recovered
FROM
    report_t
JOIN
    location_t ON report_t.area_code = location_t.area_code;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q9] Is crime more likely to be committed by relation of victims than strangers?
-- Hint: Find the distinct crime type along with the count of crime when the offender is related to the victim.*/

SELECT offender_relation, COUNT(*) AS crime_count
FROM report_t
WHERE offender_relation IS NOT NULL
GROUP BY offender_relation;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* -- [Q10] What are the methods used by the public to report a crime? 
-- Hint: Find the complaint type along with the count of crime.*/

SELECT
    complaint_type,
    COUNT(*) AS crime_count
FROM
    report_t
GROUP BY
    complaint_type;
-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



