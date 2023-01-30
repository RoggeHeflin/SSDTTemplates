CREATE SCHEMA [$rawname$];
GO

EXECUTE sp_addextendedproperty
	@name		= N'MS_Description',
	@value		= N'$rawname$ attribute, dimension, or feature values. Tables and views provide lookup, parent-child, and ancestor-descendant relationships.',
	@level0type	= N'schema',	@level0name	= N'$rawname$';
GO

/*
--	Tutorial: Using the hierarchyid Data Type
--	https://docs.microsoft.com/en-us/sql/relational-databases/tables/tutorial-using-the-hierarchyid-data-type?view=sql-server-2017

--	Hierarchical Data:			https://docs.microsoft.com/en-us/sql/relational-databases/hierarchical-data-sql-server?view=sql-server-2017
--	Common Table Expressions:	https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms186243(v=sql.105)
--	STUFF:						https://docs.microsoft.com/en-us/sql/t-sql/functions/stuff-transact-sql?view=sql-server-2017

*/