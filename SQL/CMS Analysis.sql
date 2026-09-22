select top 5 * from CMS_Cleaned

--Creating Dimentions Tables and Fact Table

SELECT DISTINCT
    [Facility ID],
    [Facility Name],
    [Address],
    [City/Town],
    [State],
    [ZIP Code],
    [County/Parish],
    [Telephone Number]
INTO Dim_Facility
FROM CMS_Cleaned;

SELECT DISTINCT
    [Measure ID],
    [Measure Name]
INTO Dim_Measure
FROM CMS_Cleaned;

SELECT DISTINCT
    [Start Date],
    [End Date]
INTO Dim_Date
FROM CMS_Cleaned;



SELECT
    [Facility ID],
    [Measure ID],
    [Start Date],
    [End Date],
    [Compared to National],
    [Denominator],
    [Score],
    [Lower Estimate],
    [Higher Estimate],
    [Number of Patients],
    [Number of Patients Returned]
INTO Fact_Performance
FROM CMS_Cleaned;

-- Creating a Star Schema

ALTER TABLE Dim_Facility
ALTER COLUMN [Facility ID] VARCHAR(20) NOT NULL;

ALTER TABLE Dim_Measure
ALTER COLUMN [Measure ID] VARCHAR(20) NOT NULL;

ALTER TABLE Dim_Date
ALTER COLUMN [Start Date] DATETIME NOT NULL;

ALTER TABLE Dim_Date
ALTER COLUMN [End Date] DATETIME NOT NULL;

ALTER TABLE Dim_Facility
ADD CONSTRAINT PK_Dim_Facility
PRIMARY KEY ([Facility ID]);

ALTER TABLE Dim_Measure
ADD CONSTRAINT PK_Dim_Measure
PRIMARY KEY ([Measure ID]);

ALTER TABLE Dim_Date
ADD CONSTRAINT PK_Dim_Date
PRIMARY KEY ([Start Date], [End Date]);

ALTER TABLE Fact_Performance
ADD CONSTRAINT FK_Fact_Facility
FOREIGN KEY ([Facility ID])
REFERENCES Dim_Facility([Facility ID]);

ALTER TABLE Fact_Performance
ADD CONSTRAINT FK_Fact_Measure
FOREIGN KEY ([Measure ID])
REFERENCES Dim_Measure([Measure ID]);

ALTER TABLE Fact_Performance
ADD CONSTRAINT FK_Fact_Date
FOREIGN KEY ([Start Date], [End Date])
REFERENCES Dim_Date([Start Date], [End Date]);

SELECT
    name AS Foreign_Key_Name
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('Fact_Performance');

-- =========================================
-- CMS HOSPITAL PERFORMANCE ANALYSIS
-- =========================================



-- Q1 : How many hospitals are included in the dataset, by state?

SELECT
    [State],
    COUNT(*) AS Hospital_Count
FROM Dim_Facility
GROUP BY [State]
ORDER BY Hospital_Count DESC;

-- Q2. Which healthcare measures have the most available scores?


SELECT TOP 10
    m.[Measure Name],
    COUNT(TRY_CONVERT(float, f.[Score])) AS Available_Scores
FROM Fact_Performance f
JOIN Dim_Measure m
    ON f.[Measure ID] = m.[Measure ID]
GROUP BY m.[Measure Name]
ORDER BY Available_Scores DESC;

-- Q3. What is the average score for each healthcare measure?

SELECT
    m.[Measure Name],
    AVG(TRY_CONVERT(float, f.[Score])) AS Average_Score
FROM Fact_Performance f
JOIN Dim_Measure m
    ON f.[Measure ID] = m.[Measure ID]
WHERE TRY_CONVERT(float, f.[Score]) IS NOT NULL
GROUP BY m.[Measure Name]
ORDER BY Average_Score DESC;

-- Q4. Which hospitals have the highest and lowest scores for each measure?

WITH RankedScores AS
(
    SELECT
        f.[Measure ID],
        m.[Measure Name],
        f.[Facility ID],
        fac.[Facility Name],
        TRY_CONVERT(float, f.[Score]) AS Score,
        RANK() OVER
        (
            PARTITION BY f.[Measure ID]
            ORDER BY TRY_CONVERT(float, f.[Score]) DESC
        ) AS Score_Rank
    FROM Fact_Performance f
    JOIN Dim_Measure m
        ON f.[Measure ID] = m.[Measure ID]
    JOIN Dim_Facility fac
        ON f.[Facility ID] = fac.[Facility ID]
    WHERE TRY_CONVERT(float, f.[Score]) IS NOT NULL
)
SELECT *
FROM RankedScores
WHERE Score_Rank <= 5
ORDER BY [Measure Name], Score_Rank;

-- Q5. How many records are better, worse, or similar to the national rate?

SELECT
    [Compared to National],
    COUNT(*) AS Record_Count
FROM Fact_Performance
WHERE [Compared to National] IN
(
    'Better Than the National Rate',
    'Worse Than the National Rate',
    'No Different Than the National Rate'
)
GROUP BY [Compared to National]
ORDER BY Record_Count DESC;

-- Q6. Which states have the most records classified as worse than the national rate?

SELECT
    fac.[State],
    COUNT(*) AS Worse_Record_Count
FROM Fact_Performance f
JOIN Dim_Facility fac
    ON f.[Facility ID] = fac.[Facility ID]
WHERE f.[Compared to National] = 'Worse Than the National Rate'
GROUP BY fac.[State]
ORDER BY Worse_Record_Count DESC;

-- Q7. What is the average number of patients returned for each healthcare measure?

SELECT
    m.[Measure Name],
    AVG(TRY_CONVERT(float, f.[Number of Patients Returned])) AS Avg_Patients_Returned
FROM Fact_Performance f
JOIN Dim_Measure m
    ON f.[Measure ID] = m.[Measure ID]
WHERE TRY_CONVERT(float, f.[Number of Patients Returned]) IS NOT NULL
GROUP BY m.[Measure Name]
ORDER BY Avg_Patients_Returned DESC;

-- Q8. Which hospitals have a high patient-return rate?

SELECT
    f.[Facility ID],
    fac.[Facility Name],
    SUM(TRY_CONVERT(float, f.[Number of Patients Returned])) * 100.0
        / NULLIF(SUM(TRY_CONVERT(float, f.[Number of Patients])), 0) AS Return_Rate
FROM Fact_Performance f
JOIN Dim_Facility fac
    ON f.[Facility ID] = fac.[Facility ID]
WHERE TRY_CONVERT(float, f.[Number of Patients Returned]) IS NOT NULL
  AND TRY_CONVERT(float, f.[Number of Patients]) IS NOT NULL
GROUP BY
    f.[Facility ID],
    fac.[Facility Name]
HAVING SUM(TRY_CONVERT(float, f.[Number of Patients])) > 0
ORDER BY Return_Rate DESC;


-- Q9. Which healthcare measures have the largest variation in scores?

SELECT
    m.[Measure Name],
    STDEV(TRY_CONVERT(float, f.[Score])) AS Score_Std_Dev
FROM Fact_Performance f
JOIN Dim_Measure m
    ON f.[Measure ID] = m.[Measure ID]
WHERE TRY_CONVERT(float, f.[Score]) IS NOT NULL
GROUP BY m.[Measure Name]
ORDER BY Score_Std_Dev DESC;


-- Q10. Which hospitals rank in the top 3 within their healthcare measures?

WITH RankedHospitals AS
(
    SELECT
        f.[Measure ID],
        m.[Measure Name],
        f.[Facility ID],
        fac.[Facility Name],
        TRY_CONVERT(float, f.[Score]) AS Score,
        RANK() OVER
        (
            PARTITION BY f.[Measure ID]
            ORDER BY TRY_CONVERT(float, f.[Score]) DESC
        ) AS Score_Rank
    FROM Fact_Performance f
    JOIN Dim_Measure m
        ON f.[Measure ID] = m.[Measure ID]
    JOIN Dim_Facility fac
        ON f.[Facility ID] = fac.[Facility ID]
    WHERE TRY_CONVERT(float, f.[Score]) IS NOT NULL
)
SELECT
    [Facility ID],
    [Facility Name],
    COUNT(*) AS Top_3_Measure_Count
FROM RankedHospitals
WHERE Score_Rank <= 3
GROUP BY
    [Facility ID],
    [Facility Name]
ORDER BY Top_3_Measure_Count DESC;


