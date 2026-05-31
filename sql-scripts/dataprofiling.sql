SELECT 
    COUNT(*) AS Total_Records,
    COUNT(Id) AS Non_Null_IDs,
    COUNT(DISTINCT Id) AS Unique_Patients,
    SUM(CASE WHEN FIRST IS NULL THEN 1 ELSE 0 END) AS Missing_First_Names,
    SUM(CASE WHEN LAST IS NULL THEN 1 ELSE 0 END) AS Missing_Last_Names,
    SUM(CASE WHEN BIRTHDATE IS NULL THEN 1 ELSE 0 END) AS Missing_Birthdays
FROM Stage_Patients;


SELECT 
    'Stage_Procedures' AS Table_Name, 
    MAX(LEN([DESCRIPTION])) AS Max_Description_Length,
    AVG(LEN([DESCRIPTION])) AS Avg_Length
FROM Stage_Procedures


SELECT 
    'Stage_Medications', 
    MAX(LEN([DESCRIPTION])),
    AVG(LEN([DESCRIPTION]))
FROM Stage_Medications



SELECT 
    'Stage_Conditions', 
    MAX(LEN([DESCRIPTION])),
    AVG(LEN([DESCRIPTION]))
FROM Stage_Conditions;


SELECT 
    MIN(BIRTHDATE) AS Oldest_Patient,
    MAX(BIRTHDATE) AS Youngest_Patient,
    COUNT(*) AS Future_Birthdays
FROM Stage_Patients


SELECT 
    MIN(BASE_ENCOUNTER_COST) AS Min_Cost,
    MAX(BASE_ENCOUNTER_COST) AS Max_Cost,
    AVG(BASE_ENCOUNTER_COST) AS Avg_Cost
FROM Stage_Encounters;


SELECT GENDER, COUNT(*) AS Count, 
       CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Percentage
FROM Stage_Patients
GROUP BY GENDER;

SELECT RACE, COUNT(*) AS Count
FROM Stage_Patients
GROUP BY RACE
ORDER BY Count DESC;


SELECT @@VERSION;