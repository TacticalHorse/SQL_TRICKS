--Необходимо использовать DAC!
--ВНИМАНИЕ: Это не стандартный способ подключения к серверу, внимательно прочтите инфтрукцию по подключению.
--SSMS: Файл => Создать => Запрос ядра СУБД => Перед названием сервера дописываем ADMIN: (Например ADMIN:DCSDB001)
--Для получения такого доступа необходима группа sysadmin для учетки
--Код основан на статье https://sqlity.net/en/1617/decrypting-encrypted-database-objects/
--Обязательно юзаем нужную бд, иначе не найдет объект. Замени YOURDB на свою
use[YOURDB]
--Пишем свое имя объекта. Замени YOUROBJECT на нужный.
DECLARE @object_name NVARCHAR(max) = 'YOUROBJECT';
DECLARE @secret VARBINARY(MAX);
DECLARE @known_encrypted VARBINARY(MAX);
DECLARE @known_plain VARBINARY(MAX);
DECLARE @object_type NVARCHAR(MAX);
SELECT @secret = imageval
FROM sys.sysobjvalues
WHERE objid = OBJECT_ID(@object_name);

DECLARE @cmd NVARCHAR(MAX);
SELECT @cmd = CASE type_desc
WHEN 'SQL_SCALAR_FUNCTION'
THEN 'ALTER FUNCTION ' + @object_name + '()RETURNS INT WITH ENCRYPTION AS BEGIN RETURN 0;END;'
WHEN 'SQL_TABLE_VALUED_FUNCTION'
THEN 'ALTER FUNCTION ' + @object_name + '()RETURNS @r TABLE(i INT) WITH ENCRYPTION AS BEGIN RETURN END;'
WHEN 'SQL_INLINE_TABLE_VALUED_FUNCTION'
THEN 'ALTER FUNCTION ' + @object_name + '()RETURNS TABLE WITH ENCRYPTION AS RETURN SELECT 0 i;'
WHEN 'SQL_STORED_PROCEDURE'
THEN 'ALTER PROCEDURE ' + @object_name + ' WITH ENCRYPTION AS RETURN 0;'
END
FROM sys.objects
WHERE object_id = OBJECT_ID(@object_name);

SELECT @cmd = REPLICATE(CAST(CHAR(32) AS NVARCHAR(MAX)), DATALENGTH(@secret)) + @cmd;

SELECT @known_plain = CAST(@cmd AS VARBINARY(MAX));

BEGIN TRAN;
EXEC(@cmd);
SELECT @known_encrypted = imageval
FROM sys.sysobjvalues
WHERE objid = OBJECT_ID(@object_name);
ROLLBACK;

DECLARE @i INT = 0;
DECLARE @plain VARBINARY(MAX) = 0x;

WHILE @i < DATALENGTH(@secret)
BEGIN
SET @plain = @plain
+ CAST(REVERSE(CAST(CAST(SUBSTRING(@secret, @i, 2) AS SMALLINT)
^ CAST(SUBSTRING(@known_plain, @i, 2) AS SMALLINT)
^ CAST(SUBSTRING(@known_encrypted, @i, 2) AS SMALLINT) AS BINARY(2))) AS BINARY(2));
SET @i += 2;
END

--Существует проблема со сдвигом байтов, кириллица бьется. 
--Байты из @plane можно сохранить через HxD или аналог и работать с ними. 
--Байты в которых содержатся значения 0x00 и 0x04 (все либо четные либо не четные) необходимо их вытянуть в начало на 2 байта. 
--Пример кода для перемещения байтов C# "bytes": for (int i = 1; i < bytes.Length-1; i = i+2) bytes[i] = bytes[i+2]; где i это байты содержащие 0x00 и 0x04
--Далее будет код по перемещению байтов, который работал для меня.
DECLARE @cnt BIGINT = 2; 
--Строим новый массив байтов учитывая правку
DECLARE @plain2 VARBINARY(max) = 0x;

WHILE @cnt< DATALENGTH(@plain)*2-2
BEGIN
	SET @plain2 = @plain2 + CAST(substring(@plain,@cnt-1,1) AS BINARY(1)) + CAST(substring(@plain,@cnt+2,1) AS BINARY(1));
	SET @cnt += 2;
END

declare @msg NVARCHAR(MAX) = cast (@plain2 AS NVARCHAR(MAX));
--print не дает вывести больше 4/8к символов для типов NVARCHAR/VARCHAR соответственно, обходим циклом на вывод
print('--------РАСШИФРОВАННАЯ ПРОЦЕДУРА--------');
declare @length int =0;
declare @printed int =0;
set @length = len(@msg);
while @printed < @length
BEGIN
    print(substring(@msg,@printed,4000));
    set @printed = @printed + 4000; 
END
print('--------КОНЕЦ--------');
