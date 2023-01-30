/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

DECLARE	@DateBeg	DATE	= '1980-01-01';
DECLARE	@DateEnd	DATE	= '2025-12-31';

INSERT INTO [dim].[Calendar] WITH(TABLOCK)
(
	[CalendarDate]
)
SELECT
	[t].*
FROM
	[dim].[Select_CalendarDates](@DateBeg, @DateEnd)	[t]
WHERE
	([t].[CalendarDate] NOT IN (SELECT [x].[CalendarDate] FROM [dim].[Calendar] [x]))
OPTION
	(MAXRECURSION 0);
GO
