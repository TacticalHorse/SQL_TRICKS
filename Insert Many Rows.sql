INSERT INTO "TableName" ("Column1","Column2","Column3")
    SELECT * FROM(VALUES
    (1, 'SomeText1', 'AnotherText1')
    , (2, 'SomeText2', 'AnotherText2')
    , (3, 'SomeText3', 'AnotherText3')
)AS tmp(col1,col2,col3);
