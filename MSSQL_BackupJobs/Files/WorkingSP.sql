Create PROCEDURE [dbo].[usp_TakeAllDatabaseBackups]    
 @path VARCHAR(256)    
AS    
    
DECLARE @name VARCHAR(80) -- database name     
--DECLARE @path VARCHAR(256) -- path for backup files     
DECLARE @fileName VARCHAR(256) -- filename for backup     
DECLARE @fileDate VARCHAR(20) -- used for file name    
declare @MD varchar(200) --used for making directory    
    
--SET @path = 'E:\Backups\DBs\SQL2022'     
SET @path = @path + CONVERT(VARCHAR(8), GETDATE(), 112) + '\'    
    
SET @MD = ' mkdir ' + @Path    
    
EXEC xp_cmdshell @MD, no_output    
    
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)    
    
DECLARE db_cursor CURSOR FOR     
SELECT name     
FROM master.dbo.sysdatabases     
WHERE name NOT IN ('tempdb')     
--WHERE name IN ('EXPSuite','Test')     
--WHERE name NOT IN ('master','model','msdb','tempdb')     
    
OPEN db_cursor      
FETCH NEXT FROM db_cursor INTO @name      
    
WHILE @@FETCH_STATUS = 0      
BEGIN      
       SET @fileName = @path + @name + '_' + @fileDate + '.BAK'     
       BACKUP DATABASE @name TO DISK = @fileName     
    
       FETCH NEXT FROM db_cursor INTO @name      
END      
    
CLOSE db_cursor      
DEALLOCATE db_cursor    
    
SELECT @path    