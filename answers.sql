-- Question 1

SELECT 
	R.Id,
	R.FirstName,
	R.MiddleName,
	R.LastName,
	W.ProjectId,
	RP.Title AS ProjectTitle
FROM Researcher R
LEFT JOIN WorksOn W
ON R.Id = W.ResearcherId
LEFT JOIN ResearchProject RP
ON W.ProjectId = RP.Id


-- Question 2

SELECT 
    RP.Id AS ProjectId,
    RP.Title AS ProjectTitle,
    CONCAT(R.FirstName, ' ', R.LastName) AS FullName,
    R.Email
FROM ResearchProject RP
INNER JOIN Researcher R 
ON RP.LeaderId = R.Id
WHERE RP.Id IN 
	(SELECT DISTINCT ProjectId FROM Funds)


-- Question 3

SELECT 
    R.Id AS ResearcherId,
    P.Id AS PublicationId
FROM Researcher R
CROSS JOIN Publication P
-- 1. very big number of rows
-- 2. consumes system resources without any benefit
-- 3. doesn't reflect real relationships (wrong result)


-- Question 4

SELECT
	S.SupervisorId,
	CONCAT(R1.FirstName, ' ', R1.LastName) AS SupervisorName,
    CONCAT(R2.FirstName, ' ', R2.LastName) AS JuniorResearcherName,
	S.SupervisionStartDate,
	S.Role
FROM Supervises S
INNER JOIN Researcher R1
ON S.SupervisorId = R1.Id
INNER JOIN Researcher R2
ON S.SupervisedId = R2.Id


-- Question 5

SELECT 
	R.Id,
	R.FirstName,
	R.LastName
FROM Researcher R
INNER JOIN Publishes P
ON P.ResearcherId = R.Id
WHERE R.Id NOT IN (
	SELECT 
		W.ResearcherId
	FROM WorksOn W
	INNER JOIN ResearchProject RP
	ON W.ProjectId = RP.Id
	WHERE RP.Status = 'Active'
)


-- Question 6

SELECT TOP 5 WITH TIES
    Title,
    PublicationDate,
    Type,
    CitationCount
FROM Publication
ORDER BY CitationCount DESC

-- Question 7

SELECT *
FROM Researcher
ORDER BY LastName
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY


-- Question 8

SELECT TOP 3 *
FROM Researcher
ORDER BY LastName
------------
SELECT *
FROM Researcher
ORDER BY LastName
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY

-- Are they functionally identical?
	-- Yes
-- What are the advantages of OFFSET-FETCH over TOP?
	-- It supports pagination
	-- Compatible with web applications
	-- Easier page management


-- Question 9

SELECT 
    Id,
    FirstName,
    LastName,
    Building,
    DateOfBirth,
    ROW_NUMBER() OVER (
        PARTITION BY Building 
        ORDER BY DateOfBirth
    ) AS BuildingIndex
FROM Researcher
ORDER BY DateOfBirth


-- Question 10

SELECT
	Title,
	Type,
	CitationCount,
	    RANK() OVER (
        PARTITION BY Type 
        ORDER BY CitationCount DESC
    ) AS Rank
FROM Publication


-- Question 11

SELECT 
    Id,
    Title,
    Status,
    Budget,
    RANK() OVER (
        PARTITION BY Status 
        ORDER BY Budget DESC
    ) AS BudgetRank
FROM ResearchProject

-- RANK() (with gaps)
	-- If there is a tie --> the same result is obtained and a number is added
	-- Example: 1, 2, 2, 4

-- DENSE_RANK() (without gaps)
	-- If there is a tie --> the same result is obtained without jumping
	-- Example: 1, 2, 2, 3


-- Question 12

SELECT 
    R.Id,
    R.FirstName,
    R.LastName,
    COUNT(P.PublicationId) AS PublicationCount,
    NTILE(4) OVER (
        ORDER BY COUNT(P.PublicationId)
    ) AS NumberOfGroup
FROM Researcher R
LEFT JOIN Publishes P 
ON R.Id = P.ResearcherId
GROUP BY R.Id, R.FirstName, R.LastName


-- Question 13

/*
1- FROM
2- WHERE
3- GROUP BY
4- HAVING
5- SELECT
6- ORDER BY
7- TOP/OFFSET-FETCH
*/


-- Question 14

SELECT ResearcherId, COUNT(*) as ProjectCount
FROM WorksOn
WHERE ProjectCount > 2 GROUP BY ResearcherId 

-- WHERE execute before SELECT
-- The correct query is

SELECT
    ResearcherId,
    COUNT(*) AS ProjectCount
FROM WorksOn
GROUP BY ResearcherId
HAVING COUNT(*) > 2


-- Question 15

SELECT
    FirstName + ' ' + ISNULL(MiddleName + ' ', '') + LastName AS FullName,
    LOWER(Email) AS Email,
    DATEDIFF(YEAR, DateOfBirth, GETDATE()) AS Age
FROM Researcher


-- Question 16

SELECT 
    Id,
    Title,
    DATEDIFF(DAY, StartDate, ISNULL(EndDate, GETDATE())) AS Duration,
    MONTH(StartDate) AS StartMonth,
    YEAR(StartDate) AS StartYear
FROM ResearchProject


-- Question 17

SELECT *
FROM Researcher
WHERE Email LIKE '%@university.edu'


-- Question 18

SELECT
    Id,
    FirstName,
    ISNULL(MiddleName, 'N/A') AS MiddleName,
    LastName,
    ISNULL(RoomNumber, 'N/A') AS RoomNumber
FROM Researcher


-- Question 19

SELECT
    Id,
    Title,
    Status,
    Budget,
    CASE
        WHEN Budget < 50000 THEN 'Small'
        WHEN Budget BETWEEN 50000 AND 150000 THEN 'Medium'
        ELSE 'Large'
    END 
    AS BudgetCategory
FROM ResearchProject
 

-- Question 20

SELECT
    R.FirstName + ' ' + ISNULL(R.MiddleName, '') + ' ' + R.LastName AS FullName,
    SUM(RP.Budget) AS TotalBudget
FROM ResearchProject RP
INNER JOIN Researcher R
ON RP.LeaderId = R.Id
GROUP BY R.FirstName, R.MiddleName, R.LastName


-- Question 21

SELECT 
    Building,
    COUNT(*) AS ResearcherCount
FROM Researcher
GROUP BY Building
HAVING COUNT(*) > 3


-- Question 22

SELECT
    AVG(CitationCount) AS AverageCitations,
    SUM(CitationCount) AS TotalCitations,
    COUNT(*) AS PublicationCount
FROM Publication
GROUP BY Type
HAVING AVG(CitationCount) > 50


-- Question 23

SELECT
    ResearcherId,
    COUNT(ProjectId) AS ProjectCount,
    SUM(HoursPerWeek) AS TotalHours
FROM WorksOn
GROUP BY ResearcherId
HAVING COUNT(ProjectId) > 2
       AND SUM(HoursPerWeek) > 60


-- Question 24

SELECT *
FROM ResearchProject
WHERE Budget > (
    SELECT AVG(Budget)
    FROM ResearchProject
)


-- Question 25

WITH PublicationCount AS (
    SELECT 
        R.Id,
        R.FirstName,
        R.LastName,
        R.Building,
        COUNT(P.PublicationId) AS TotalPublications
    FROM Researcher R
    LEFT JOIN Publishes P 
    ON R.Id = P.ResearcherId
    GROUP BY R.Id, R.FirstName, R.LastName, R.Building
)
SELECT *
FROM PublicationCount
WHERE TotalPublications > (
    SELECT AVG(TotalPublications)
    FROM PublicationCount P2
    WHERE p2.Building = PublicationCount.Building
)


-- Question 26

SELECT *
FROM Researcher R
WHERE EXISTS (
    SELECT 1
    FROM Supervises S
    WHERE S.SupervisorId = R.Id
)


-- Question 27

SELECT
    RP.Id,
    RP.Title,
    (
        SELECT COUNT(*)
        FROM WorksOn W
        WHERE W.ProjectId = RP.Id
    ) AS ResearchersCount
FROM ResearchProject RP


-- Question 28

SELECT MAX(Budget) AS SecondHighestBudget
FROM ResearchProject
WHERE Budget < (
    SELECT MAX(Budget)
    FROM ResearchProject
)


-- Question 29

SELECT Email AS ContactInformation
FROM Researcher

UNION ALL

SELECT FundingAgency 
FROM Grants

-- UNION --> Delete duplicates
-- UNION ALL --> Fast and does not delete duplicates


-- Question 30

SELECT DISTINCT 
    R.Id, 
    R.FirstName, 
    R.LastName
FROM Researcher R
INNER JOIN WorksOn W
ON R.Id = W.ResearcherId
WHERE R.Id NOT IN (
    SELECT ResearcherId
    FROM Publishes
)


-- Question 31

SELECT DISTINCT
    R.Id,
    R.FirstName,
    R.LastName
FROM Researcher R
INNER JOIN Supervises S
ON R.Id = S.SupervisorId
INNER JOIN ResearchProject RP
ON R.Id = RP.LeaderId


-- Question 32

WITH TotalHours AS (
    SELECT
        ResearcherId,
        SUM(HoursPerWeek) AS TotalHours
    FROM WorksOn
    GROUP BY ResearcherId
)
SELECT *
FROM TotalHours
WHERE TotalHours > 40


-- Question 33

WITH TotalBudget AS (
    SELECT
        LeaderId,
        SUM(Budget) AS TotalBudget
    FROM ResearchProject
    GROUP BY LeaderId
),
TotalPublication AS (
    SELECT
        ResearcherId,
        COUNT(*) AS TotalPublicationCount
    FROM Publishes
    GROUP BY ResearcherId
)

SELECT
    R.Id,
    R.FirstName,
    R.LastName,
    TB.TotalBudget,
    TP.TotalPublicationCount
FROM Researcher R
INNER JOIN TotalBudget TB
ON R.Id = TB.LeaderId
INNER JOIN TotalPublication TP
ON R.Id = TP.ResearcherId
WHERE TB.TotalBudget > 100000
    AND TP.TotalPublicationCount >= 3


-- Question 34

GO
CREATE FUNCTION ProjectDurationInDays (@ProjectId INT)
RETURNS INT
AS
BEGIN

    DECLARE @Days INT;
    SELECT
        @Days = DATEDIFF(DAY, StartDate, ISNULL(EndDate, GETDATE()))
    FROM ResearchProject
    WHERE Id = @ProjectId;

    RETURN @Days;
END
GO


-- Question 35

GO
CREATE FUNCTION GetresearcherData (@ResearcherId INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        RP.Title,
        W.Role,
        W.HoursPerWeek
    FROM WorksOn W
    INNER JOIN ResearchProject RP
    ON W.ProjectId = RP.Id
    WHERE W.ResearcherId = @ResearcherId
)
GO


-- Question 36

GO
CREATE FUNCTION GetResearcherInfo (@ResearcherId INT)
RETURNS @Result TABLE (
    NumberOfProjects INT,
    NumberOfPublications INT,
    TotalHours INT,
    AvgCitations FLOAT
)
AS
BEGIN
    INSERT INTO @Result
    SELECT
        (SELECT COUNT(*) FROM WorksOn WHERE ResearcherId = @ResearcherId),
        (SELECT COUNT(*) FROM Publishes WHERE ResearcherId = @ResearcherId),
        (SELECT ISNULL(SUM(HoursPerWeek),0) FROM WorksOn WHERE ResearcherId = @ResearcherId),
        (SELECT AVG(CitationCount)
         FROM Publication Publication
         INNER JOIN Publishes Publishes
         ON Publication.Id = Publishes.PublicationId
         WHERE Publishes.ResearcherId = @ResearcherId)
    RETURN
END
GO

/*
1- Inline TVF:
    - Better when the query is simple

2- Multi-statement TVF:
    - We calculate more than one value
    - More complex logic
*/

-- Question 37

CREATE NONCLUSTERED INDEX IX_ResearchProject_Status_StartDate
ON ResearchProject (Status, StartDate)


-- Question 38

/*
1- Clustered Index:
    - Determines the physical order of data rows in a table
    - The table data itself is stored in the order of the clustered index key
    - Each table can have only one clustered index

2- Non-Clustered Index:
    - Contains the indexed column values and a pointer to the actual data row
    - Separate structure from the table data
    - A table can have multiple non-clustered indexes
    - It does not change the physical order of the table

3- When we create a clustered index:
    - Any existing non-clustered index will automatically update to reflect the new ranking
*/


-- Question 39


CREATE NONCLUSTERED INDEX IX_ResearchProject_Email_FullName
ON Researcher (Email)
INCLUDE (FirstName, LastName)

/*
- covering index is an index that contains all the columns needed to satisfy a query
- The query filters by Email and return FirstName and LastName
- All required data exists inside the index
    so, we does not need to access the base table witch improves query performance
*/


-- Question 40

GO
CREATE VIEW ActiveProjectSummary
AS 
SELECT
    RP.Title AS ProjectTitle,
    CONCAT(R.FirstName, ' ', R.LastName) AS LeaderName,
    COUNT(W.ResearcherId) AS TeamMembers,
    SUM(W.HoursPerWeek) AS TotalHoursPerWeek,
    RP.Budget AS TotalBudget
FROM ResearchProject RP
INNER JOIN Researcher R
ON RP.LeaderId = R.Id
LEFT JOIN WorksOn W
ON RP.LeaderId = W.ResearcherId
GROUP BY RP.Title, R.FirstName, R.LastName, RP.Budget
GO


-- Question 41

CREATE OR ALTER VIEW ResearcherPublicationStats
WITH SCHEMABINDING
AS
SELECT
    R.Id AS ResearcherId,
    R.FirstName,
    R.LastName,
    COUNT_BIG(*) AS TotalPublications
FROM dbo.Researcher R
INNER JOIN dbo.Publishes P
ON R.Id = P.ResearcherId
GROUP BY R.Id, R.FirstName, R.LastName
GO

CREATE UNIQUE CLUSTERED INDEX IX_ResearcherPublicationStats
ON dbo.ResearcherPublicationStats (ResearcherId)


-- Question 42

/*
1- Requirements:
    - Must use WITH SCHEMABINDING
    - Can not use (SELECT *)
    - Use COUNT_BIG() insted of COUNT()
    - No LEFT/RIGHT/FULL JOIN (Only INNER JOIN is allowed)
    - No UNION or DISTINCT
    - No Aggregates: MIN(), MAX(), or AVG()
    - No Non-deterministic functions like: GETDATE()

2- Performance Benefits:
    - Data is materialized and stored
    - Faster reads for complex aggregate queries

3- When to use an indexed view:
    - Reporting and analytics queries
    - Frequent aggregations
*/


-- Question 43

GO
CREATE OR ALTER PROC dbo.AddResearcherToProject

@ResearcherId VARCHAR(10),
@ProjectId VARCHAR(10),
@JoinDate DATE,
@Role NVARCHAR(50),
@HoursPerWeek INT,
@Result INT OUT

AS
BEGIN
    SET @Result = 0;

    IF NOT EXISTS (SELECT 1 FROM Researcher WHERE Id = @ResearcherId)
        BEGIN
            SET @Result = -1;
            RETURN
        END

    IF NOT EXISTS (SELECT 1 FROM ResearchProject WHERE Id = @ProjectId)
        BEGIN
            SET @Result = -1;
            RETURN
        END

    IF EXISTS (
        SELECT 1 FROM WorksOn 
        WHERE ResearcherId = @ResearcherId AND ProjectId = @ProjectId
    )
        BEGIN
            SET @Result = -1;
            RETURN
        END
        
    INSERT INTO WorksOn (ResearcherId, ProjectId, JoinDate, Role, HoursPerWeek)
    VALUES (@ResearcherId, @ProjectId, @JoinDate, @Role, @HoursPerWeek)
END


DECLARE @Status INT;

EXEC AddResearcherToProject
    @ResearcherId = 'R001',
    @ProjectId = 'P001',
    @JoinDate = '2022-01-01',
    @Role = 'Researcher',
    @HoursPerWeek = 40,
    @Result = @Status OUT

SELECT @Status AS Result


-- Question 44

GO
CREATE PROC dbo.UpdateProjectStatus
@ProjectId VARCHAR(10)
AS
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM ResearchProject 
        WHERE Id = @ProjectId AND Status = 'Pending'
    )
        RETURN -1

    IF NOT EXISTS (
        SELECT 1 
        FROM WorksOn 
        WHERE ProjectId = @ProjectId
    )
        RETURN -1

    IF NOT EXISTS (
        SELECT 1 
        FROM Funds 
        WHERE ProjectId = @ProjectId
    )
        RETURN -1

    UPDATE ResearchProject
    SET Status = 'Active'
    WHERE Id = @ProjectId

    RETURN 0
END

DECLARE @Result INT;

EXEC @Result = dbo.UpdateProjectStatus 
     @ProjectId = P002

SELECT @Result AS Result


-- Question 45

GO
CREATE PROC dbo.GetResearcherSummary
@ResearcherId VARCHAR(10),
@TotalProjects INT OUT,
@TotalPublications INT OUT,
@TotalWeeklyHours INT OUT

AS
BEGIN
    SELECT 
        @TotalProjects = COUNT(*),
        @TotalWeeklyHours = ISNULL(SUM(HoursPerWeek), 0)
    FROM WorksOn
    WHERE ResearcherId = @ResearcherId

    SELECT @TotalPublications = COUNT(*)
    FROM Publishes
    WHERE ResearcherId = @ResearcherId
 
END


-- Question 46

GO
CREATE TRIGGER trg_ProjectsForEveryResearcher
ON WorksOn
AFTER INSERT
AS
BEGIN
    DECLARE @ResearcherId VARCHAR(10);

    SELECT @ResearcherId = ResearcherId
    FROM inserted

    IF(
        SELECT COUNT(*)
        FROM WorksOn
        WHERE ResearcherId = @ResearcherId
    ) > 5
    BEGIN
        ROLLBACK;
        THROW 50001, 'Researcher can not work on more than 5 projects', 1
    END
END


-- Question 47

GO
CREATE TRIGGER trg_UpdateProjectStatus
ON ResearchProject
AFTER UPDATE
AS
BEGIN
    UPDATE ResearchProject
    SET Status = 'Completed'
    WHERE Id IN (
        SELECT Id
        FROM inserted
        WHERE EndDate IS NOT NULL
            AND EndDate < GETDATE()
    )
END


-- Question 48

CREATE TABLE GrantsAudit (
    GrantId INT,
    OldAmount DECIMAL(10,2),
    NewAmount DECIMAL(10,2),
    ModifiedBy NVARCHAR(100),
    ModifiedDate DATETIME
)

GO
CREATE TRIGGER trg_GrantsAudit 
ON Grants
AFTER UPDATE 
AS
BEGIN
    INSERT INTO GrantsAudit (GrantId, OldAmount, NewAmount, ModifiedBy, ModifiedDate)

    SELECT 
        d.Id,
        d.Amount,
        i.Amount,
        SYSTEM_USER,
        GETDATE()
    FROM deleted d
    INNER JOIN inserted i
    ON d.Id = i.Id
END


-- Question 49

BEGIN TRY
    BEGIN TRAN

    INSERT INTO ResearchProject (Id, Title, StartDate, EndDate, Budget, Status, LeaderId)
    VALUES ('P200', 'ProjectTitle', GETDATE(), '2027-01-01', 3000000, 'Pending', 'R099')

    DECLARE @ProjectId VARCHAR(10)  = 'P200'

    INSERT INTO WorksOn (ResearcherId, ProjectId, JoinDate, Role, HoursPerWeek)
    VALUES (1, @ProjectId, GETDATE(), 'Leader', 20)

    INSERT INTO Funds
    VALUES (1, @ProjectId, 50000, GETDATE())

    COMMIT
END TRY

BEGIN CATCH
    ROLLBACK
END CATCH


-- Question 50

/*

ACID Properties of Transactions:

1- Atomicity
    - A transaction is executed as a single unit, all operations succeed or all are rolled back
    - If inserting a project, assigning a leader, and allocating a grant fails at any step, none of the changes are saved

2- Consistency
    - A transaction moves the database from one valid state to another, following all constraints
    - A project cannot be Active unless it has researchers or funding

3- Isolation
    - Transactions run independently without affecting each other
    - If there are two users updating different projects at the same time, this does not interfere

4- Durability
    - Once a transaction is committed, the data is stored
*/


-- Question 51

-- 1) Give user 'ResearchManager' full permissions on all tables

CREATE LOGIN ResearchManager WITH PASSWORD = 'P@$$w0rd!'
CREATE USER ResearchManager FOR LOGIN ResearchManager

GRANT SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::dbo
TO ResearchManager

-- 2) Give user 'ResearchAssistant' SELECT and INSERT permissions only on Researcher and Publication tables
CREATE LOGIN ResearchAssistant WITH PASSWORD = 'P@$$w0rd'
CREATE USER ResearchAssistant FOR LOGIN ResearchAssistant

GRANT SELECT, INSERT
ON dbo.Researcher
TO ResearchAssistant

GRANT SELECT, INSERT
ON dbo.Publication
TO ResearchAssistant

-- 3) Give user 'DataAnalyst' SELECT permission on all views but no direct table access
CREATE LOGIN DataAnalyst WITH PASSWORD = 'P@$$w0rd?'
CREATE USER DataAnalyst FOR LOGIN DataAnalyst

GRANT SELECT ON dbo.ActiveProjectSummary TO DataAnalyst
GRANT SELECT ON dbo.ResearcherPublicationStats TO DataAnalyst


-- Question 52

REVOKE INSERT, UPDATE
ON dbo.Researcher
FROM ResearchAssistant

/*
- GRANT: give a user access to do an action
- REVOKE: remove a permission that granted before
- DENY: block a permission, even if granted through another role or permission
*/


-- Question 53

-- Query A:
SELECT r.*
FROM Researcher r
WHERE r.Id IN (SELECT ResearcherId FROM WorksOn WHERE ProjectId = 'P001')


-- Query B:
SELECT r.*
FROM Researcher r
WHERE EXISTS (SELECT 1 FROM WorksOn w WHERE w.ResearcherId = r.Id AND w.ProjectId = 'P001')

/*
- Performance:
Query B is better on large dataset because it stops searching once a match is found
Query A scan all subquery result

- What factors influence the optimizer's choice?
    - Number of rows in WorksOn table
    - Indexes on WorksOn (ProjectId, ResearcherId)
*/


-- Question 54

SELECT p.Title, r.FirstName, r.LastName
FROM ResearchProject p LEFT JOIN WorksOn w
ON p.Id = w.ProjectId
LEFT JOIN Researcher r
ON w.ResearcherId = r.Id
WHERE p.Status = 'Active'
ORDER BY p.StartDate DESC

-- 1) Add index

CREATE INDEX IX_ResearchProject_Status_StartDate_
ON ResearchProject(Status, StartDate)

CREATE INDEX IX_WorksOn_ProjectId
ON WorksOn(ProjectId)

-- 2) Rewrite the query

-- use INNER JOIN insted of LEFT JOIN if you only need projects with researchers

-- 3) Use CTE

GO
WITH ActiveProjects AS (
    SELECT
        Id,
        Title,
        StartDate
    FROM ResearchProject
    WHERE Status = 'Active'
)

SELECT
    AP.Title,
    R.FirstName,
    R.LastName
FROM ActiveProjects AP
INNER JOIN WorksOn W
ON AP.Id = W.ProjectId
INNER JOIN Researcher R
ON W.ResearcherId = R.Id
ORDER BY AP.StartDate DESC


-- Question 55

/*

A: Write query each time
    - Pros: Simple, no extra objects
    - Cons: Repetitive, slower for large data

B: Create view
    - Pros: Reusable, easy
    - Cons: Not indexed --> may be slow on large datasets

C: Stored procedure
    - Pros: Fast execution, reusable
    - Cons: Need parameters

D: Indexed view
    - Pros: Very fast
    - Cons: More maintenance, restrictions on join or aggregates

- If data is queried frequently and performance is very important, we will use Indexed view

- If we need flexibility (reusable) and allow some execution time, we will use stored procedure or view
*/