
CREATE VIEW [internal].[current_user_readable_projects]
AS
SELECT     [object_id] AS [id]
FROM       [catalog].[effective_object_permissions]
WHERE      [object_type] = 2
           AND  [permission_type] = 1
