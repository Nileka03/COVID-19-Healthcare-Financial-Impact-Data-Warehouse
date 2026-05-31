CREATE PROCEDURE dbo.UpdateDimCondition 
    @ConditionCode nvarchar(50), 
    @Description nvarchar(1000), 
    @IsCovidFlag nvarchar(3) 
AS 
BEGIN 
    
    IF NOT EXISTS (SELECT ConditionSK 
                   FROM dbo.DimCondition 
                   WHERE ConditionCode = @ConditionCode) 
    BEGIN 
        INSERT INTO dbo.DimCondition 
        (ConditionCode, [Description], IsCovidFlag, InsertDate) 
        VALUES 
        (@ConditionCode, @Description, @IsCovidFlag, GETDATE()) 
    END; 

    
    IF EXISTS (SELECT ConditionSK 
               FROM dbo.DimCondition 
               WHERE ConditionCode = @ConditionCode) 
    BEGIN 
        UPDATE dbo.DimCondition 
        SET [Description] = @Description, 
            IsCovidFlag = @IsCovidFlag
        WHERE ConditionCode = @ConditionCode 
    END; 
END;

----------------------------------------------------------------
CREATE PROCEDURE dbo.UpdateDimMedication
    @MedicationID nvarchar(100),
    @Description nvarchar(1000),
    @BaseCost decimal(18,2)
AS
BEGIN
    
    IF NOT EXISTS (SELECT MedicationSK FROM dbo.DimMedication WHERE MedicationID = @MedicationID)
    BEGIN
        
        INSERT INTO dbo.DimMedication (MedicationID, [Description], BaseCost, InsertDate)
        VALUES (@MedicationID, @Description, @BaseCost, GETDATE());
    END
    ELSE
    BEGIN
        
        UPDATE dbo.DimMedication
        SET [Description] = @Description,
            BaseCost = @BaseCost
        WHERE MedicationID = @MedicationID;
    END
END;

----------------------------------------------------

CREATE PROCEDURE dbo.UpdateDimProcedures
    @ProcedureCode nvarchar(50),
    @Description nvarchar(1000),
    @BaseCost decimal(18,2)
AS
BEGIN
    
    IF NOT EXISTS (SELECT ProcedureSK 
                   FROM dbo.DimProcedures 
                   WHERE ProcedureCode = @ProcedureCode)
    BEGIN
       
        INSERT INTO dbo.DimProcedures 
            (ProcedureCode, [Description], BaseCost, InsertDate)
        VALUES 
            (@ProcedureCode, @Description, @BaseCost, GETDATE());
    END
    ELSE
    BEGIN
        
        UPDATE dbo.DimProcedures
        SET [Description] = @Description,
            BaseCost = @BaseCost
        WHERE ProcedureCode = @ProcedureCode;
    END
END;


--------------------------------------------
CREATE PROCEDURE dbo.UpdateDimPayer
    @PayerID nvarchar(100),
    @Name nvarchar(255),
    @Address nvarchar(255),
    @City nvarchar(100),
    @State nvarchar(50),
    @Zip nvarchar(20),
    @Phone nvarchar(50)
AS
BEGIN
   
    IF NOT EXISTS (SELECT PayerSK FROM dbo.DimPayer WHERE PayerID = @PayerID)
    BEGIN
        
        INSERT INTO dbo.DimPayer 
            (PayerID, [Name], [Address], City, [State], Zip, Phone, InsertDate)
        VALUES 
            (@PayerID, @Name, @Address, @City, @State, @Zip, @Phone, GETDATE());
    END
    ELSE
    BEGIN
       
        UPDATE dbo.DimPayer
        SET [Name] = @Name,
            [Address] = @Address,
            City = @City,
            [State] = @State,
            Zip = @Zip,
            Phone = @Phone
        WHERE PayerID = @PayerID;
    END
END;

----------------------------------------------------------------
DROP PROCEDURE dbo.UpdateDimOrganization;

CREATE OR ALTER PROCEDURE dbo.UpdateDimOrganization
    @OrgID nvarchar(100),
    @Name nvarchar(255),
    @Address nvarchar(255),
    @City nvarchar(100),
    @State nvarchar(50),
    @Zip nvarchar(20),
    @Phone nvarchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT OrgSK FROM dbo.DimOrganization WHERE OrgID = @OrgID)
    BEGIN
        INSERT INTO dbo.DimOrganization 
            (OrgID, OrgName, [Address], City, [State], Zip, Phone, InsertDate)
        VALUES 
            (@OrgID, @Name, @Address, @City, @State, @Zip, @Phone, GETDATE());
    END
    ELSE
    BEGIN
        UPDATE dbo.DimOrganization
        SET OrgName = @Name,
            [Address] = @Address,
            City = @City,
            [State] = @State,
            Zip = @Zip,
            Phone = @Phone
        WHERE OrgID = @OrgID;
    END
END;
-----------------------------------------------
CREATE OR ALTER PROCEDURE dbo.UpdateDimProvider
    @ProviderID nvarchar(100),
    @Name nvarchar(255),
    @Specialty nvarchar(255),
    @OrgKey int
AS
BEGIN
    
    IF NOT EXISTS (SELECT ProviderSK FROM dbo.DimProvider WHERE ProviderID = @ProviderID)
    BEGIN
      
        INSERT INTO dbo.DimProvider (ProviderID, [Name], Specialty, OrgKey, InsertDate)
        VALUES (@ProviderID, @Name, @Specialty, @OrgKey, GETDATE());
    END
    ELSE
    BEGIN
        
        UPDATE dbo.DimProvider
        SET [Name] = @Name,
            Specialty = @Specialty,
            OrgKey = @OrgKey
        WHERE ProviderID = @ProviderID;
    END
END;

------------------------------------------------------------------

DECLARE @date DATE = '1900-01-01'
WHILE @date < '2010-01-01'
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, Day, DayName, IsWeekend)
    VALUES (
        CAST(FORMAT(@date, 'yyyyMMdd') AS INT),
        @date,
        YEAR(@date),
        DATEPART(QUARTER, @date),
        MONTH(@date),
        DATENAME(MONTH, @date),
        DAY(@date),
        DATENAME(WEEKDAY, @date),
        CASE WHEN DATEPART(WEEKDAY, @date) IN (1,7) THEN 1 ELSE 0 END
    )
    SET @date = DATEADD(DAY, 1, @date)
END