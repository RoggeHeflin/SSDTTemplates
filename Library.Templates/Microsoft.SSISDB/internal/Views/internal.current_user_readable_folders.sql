
CREATE VIEW [internal].[current_user_readable_folders]
AS
SELECT     [object_id] AS [id]
FROM       [catalog].[effective_object_permissions]
WHERE      [object_type] = 1
           AND  [permission_type] = 1
