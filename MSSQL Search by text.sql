USE[YourBase]
SELECT SCHEMA_NAME(o.schema_id), OBJECT_NAME(o.object_id), o.type
FROM syscomments c INNER JOIN sys.objects o ON c.id = o.object_id
WHERE
c.text like '%TEXT%'
