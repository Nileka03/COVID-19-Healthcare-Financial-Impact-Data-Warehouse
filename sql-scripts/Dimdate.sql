
DECLARE @StartDate DATE = '2010-01-01', @EndDate DATE = '2030-12-31';
WHILE @StartDate <= @EndDate
BEGIN
    INSERT INTO DimDate (DateKey, FullDate, Year, Quarter, Month, MonthName, Day, DayName, IsWeekend)
    SELECT 
        CAST(FORMAT(@StartDate, 'yyyyMMdd') AS INT), 
        @StartDate, YEAR(@StartDate), DATEPART(QUARTER, @StartDate), 
        MONTH(@StartDate), DATENAME(MONTH, @StartDate), DAY(@StartDate), 
        DATENAME(WEEKDAY, @StartDate),
        CASE WHEN DATENAME(WEEKDAY, @StartDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END;
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;

