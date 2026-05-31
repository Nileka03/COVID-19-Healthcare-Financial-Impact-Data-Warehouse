-- DEV/DEBUG UTILITY SCRIPTS
-- These scripts were used during development 
-- for testing, schema adjustments, and reseeding.
-- Not intended for production use.


SELECT COUNT(*) FROM Stage_Encounters;

SELECT TOP 10 EncounterID, accm_txn_create_time 
FROM FactEncounter;


SELECT COUNT(*) FROM Stage_Providers;

SELECT TOP 5 Id, ORGANIZATION, NAME 
FROM Stage_Providers

SELECT TOP 5 OrgSK, OrgID, OrgName 
FROM DimOrganization

EXEC dbo.UpdateDimOrganization 
    '3cd8dc71-7a8c-312f-8812-39165c5f58ac',
    'Test Org',
    '123 Main St',
    'Boston',
    'MA',
    '02101',
    '555-1234'

SELECT * FROM DimOrganization 
WHERE OrganizationID = '3cd8dc71-7a8c-312f-8812-39165c5f58ac'

DELETE FROM DimOrganization WHERE OrgSK = 1289

select * from DimOrganization

select * from DimProvider

SELECT COUNT(*) FROM DimProvider

SELECT TOP 5 * FROM DimProvider

DELETE FROM DimProvider

EXEC sp_helptext 'UpdateDimProvider'

SELECT COUNT(*) FROM DimPatient;


SELECT Org
, COUNT(*) FROM DimOrganization GROUP BY OrganizationID HAVING COUNT(*) > 1;



SELECT COUNT(DISTINCT PROVIDER) FROM Stage_Encounters

SELECT COUNT(*) FROM DimProvider


SELECT COUNT(DISTINCT e.PROVIDER) 
FROM Stage_Encounters e
JOIN DimProvider p ON TRIM(e.PROVIDER) = TRIM(p.ProviderID)


SELECT OrgID, COUNT(*) 
FROM DimOrganization 
GROUP BY OrgID 
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC

ALTER TABLE DimProvider NOCHECK CONSTRAINT ALL

DELETE FROM DimOrganization

ALTER TABLE DimProvider CHECK CONSTRAINT ALL

SELECT OrgID, COUNT(*) FROM DimOrganization 
GROUP BY OrgID ORDER BY COUNT(*) DESC

DELETE FROM DimProvider

SELECT COUNT(*) FROM DimProvider
SELECT TOP 5 * FROM DimProvider

SELECT COUNT(*) FROM DimPatient
SELECT TOP 5 * FROM DimPatient



ALTER TABLE dbo.FactEncounter
ADD 
    accm_txn_create_time DATETIME NULL,
    accm_txn_complete_time DATETIME NULL,
    txn_process_time_hours FLOAT NULL




CREATE TABLE dbo.Stage_EncounterCompletions (
    txn_id NVARCHAR(100),
    accm_txn_complete_time DATETIME
)

INSERT INTO dbo.Stage_EncounterCompletions
SELECT TOP 10 EncounterID, DATEADD(DAY, 2, accm_txn_create_time)
FROM dbo.FactEncounter
WHERE accm_txn_create_time IS NOT NULL

SELECT MIN(FullDate), MAX(FullDate) 
FROM DimDate

SELECT TOP 1 * FROM DimDate


ALTER TABLE dbo.FactEncounter
DROP COLUMN txn_process_time_hours

ALTER TABLE dbo.FactEncounter  
ADD txn_process_time_hours AS 
    DATEDIFF(HOUR, accm_txn_create_time, accm_txn_complete_time)


    select * from Stage_Conditions

    ----------------------------------------------------------

    select * from DimProvider
DELETE FROM dbo.FactEncounter;
DELETE FROM DimProvider;
DBCC CHECKIDENT ('dbo.FactEncounter', RESEED, 0);
DBCC CHECKIDENT ('dbo.DimProvider', RESEED, 0);

select * from DimPatient
DELETE FROM DimPatient;
DBCC CHECKIDENT ('dbo.DimPatient', RESEED, 0);

select * from FactEncounter

select * from DimDate

DELETE FROM FactEncounter;
DBCC CHECKIDENT ('FactEncounter', RESEED, 0);

ALTER TABLE FactEncounter DROP COLUMN txn_process_time_hours;

ALTER TABLE FactEncounter 
ADD txn_process_time_hours AS (DATEDIFF(HOUR, accm_txn_create_time, accm_txn_complete_time));


ALTER TABLE FactEncounter DROP COLUMN txn_process_time_hours;


ALTER TABLE FactEncounter ADD txn_process_time_hours INT;


ALTER TABLE dbo.FactEncounter
DROP COLUMN PatientResponsibility;

ALTER TABLE dbo.FactEncounter
ADD PatientResponsibility DECIMAL(18,2) NULL;