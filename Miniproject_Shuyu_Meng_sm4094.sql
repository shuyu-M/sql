-- 1
SELECT
    TRIM(SUBSTRING_INDEX(a.Name, ':', 1)) AS Airline_Name,     
    MAX(f.DepDelay) AS max_dep_delay
FROM FAA.al_perf AS f
JOIN FAA.L_AIRLINE_ID AS a
  ON f.Reporting_Airline = SUBSTRING_INDEX(a.Name, ': ', -1)  
GROUP BY Airline_Name
ORDER BY max_dep_delay ASC;


-- 2
SELECT
    TRIM(SUBSTRING_INDEX(a.Name, ':', 1)) AS Airline_Name,      
    MIN(f.DepDelay) AS max_early_departure                      
FROM FAA.al_perf AS f
JOIN FAA.L_AIRLINE_ID AS a
  ON f.Reporting_Airline = SUBSTRING_INDEX(a.Name, ': ', -1)    
GROUP BY Airline_Name
ORDER BY max_early_departure ASC;

-- 3) Rank weekdays by total number of flights (1 = busiest)

SELECT
    w.Day AS Day_Name,                                  -- Name of the weekday
    COUNT(*) AS num_flights,                            -- Total number of flights on that weekday
    RANK() OVER (ORDER BY COUNT(*) DESC) AS day_rank    -- Rank based on flight count (DESC → busiest gets rank 1)
FROM FAA.al_perf AS f
JOIN FAA.L_WEEKDAYS AS w
    ON f.DayOfWeek = w.Code                             -- Match weekday code (1–7)
GROUP BY w.Code, w.Day                                  -- Group by weekday
ORDER BY day_rank ASC;                                  -- Sort by rank (increasing)

-- 4) Find the airport with the highest average departure delay (treat early departures as 0)

SELECT
    a.Name AS Airport_Name,                                   -- Full airport name
    a.Code AS Airport_Code,                                   -- 3-letter airport code (e.g., JFK, LAX)
    AVG(
        CASE 
            WHEN f.DepDelay < 0 THEN 0                        -- Early departures count as 0 minutes delay
            ELSE f.DepDelay
        END
    ) AS avg_dep_delay                                        -- Average (non-negative) departure delay in minutes
FROM FAA.al_perf AS f
JOIN FAA.L_AIRPORT AS a
    ON f.Origin = a.Code                                      -- Match origin airport code to airport dimension
GROUP BY a.Code, a.Name                                       -- One row per airport
ORDER BY avg_dep_delay DESC                                   -- Highest average delay first
LIMIT 1;                                                      -- Keep only the worst (most delayed) airport

-- 5
SELECT
    t.Reporting_Airline AS Airline_Code,
    ap.Name AS Airport_Name,
    t.avg_dep_delay
FROM (
    SELECT
        Reporting_Airline,
        OriginAirportID,
        AVG(GREATEST(DepDelay, 0)) AS avg_dep_delay,
        ROW_NUMBER() OVER (
            PARTITION BY Reporting_Airline
            ORDER BY AVG(GREATEST(DepDelay, 0)) DESC
        ) AS rn
    FROM FAA.al_perf
    GROUP BY Reporting_Airline, OriginAirportID
) AS t
JOIN FAA.L_AIRPORT_ID AS ap
    ON t.OriginAirportID = ap.ID
WHERE t.rn = 1
ORDER BY Airline_Code;

-- 6a) Count how many canceled flights exist in the dataset
SELECT 
    COUNT(*) AS num_canceled_flights   -- Total number of canceled flights
FROM FAA.al_perf
WHERE Cancelled = 1;

-- 6b) For each departure airport, find the most frequent cancelation reason

WITH cancel_counts AS (
    SELECT
        f.Origin AS Airport_Code,          -- Airport where the flight departed
        f.CancellationCode AS Cancel_Code, -- Cancelation reason code (A/B/C/D)
        COUNT(*) AS cancel_total           -- Number of cancelations for this reason
    FROM FAA.al_perf AS f
    WHERE f.Cancelled = 1                  -- Only canceled flights
    GROUP BY f.Origin, f.CancellationCode
),

ranked AS (
    SELECT
        c.*,
        RANK() OVER (
            PARTITION BY c.Airport_Code
            ORDER BY c.cancel_total DESC   -- Highest count = rank 1
        ) AS reason_rank
    FROM cancel_counts AS c
)

SELECT
    r.Airport_Code,                        -- Departure airport code
    l.Reason AS Cancel_Reason,             -- Text description of the reason
    r.cancel_total AS Num_Cancelations     -- Number of cancelations for this reason
FROM ranked AS r
JOIN FAA.L_CANCELATION AS l
    ON r.Cancel_Code = l.Code              -- Lookup reason text
WHERE r.reason_rank = 1                    -- Keep only the most frequent reason per airport
ORDER BY r.cancel_total DESC;              -- Optional: sort by number of cancelations


-- 7) For each calendar day, show the average number of flights
--    over the preceding 3 days (not including the current day)

-- Step 1: count number of flights per calendar day
WITH daily_counts AS (
    SELECT
        f.FlightDate,                 -- Calendar date
        COUNT(*) AS num_flights       -- Total flights on this date
    FROM FAA.al_perf AS f
    GROUP BY f.FlightDate
)

-- Step 2: compute 3-day rolling average of flights
SELECT
    d.FlightDate,
    d.num_flights,
    AVG(d.num_flights) OVER (
        ORDER BY d.FlightDate
        ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ) AS avg_flights_prev_3_days     -- Average over previous 3 days
FROM daily_counts AS d
ORDER BY d.FlightDate;
