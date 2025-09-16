begin
    for i in (select table_name from user_tables where owner='HR' and table_name = 'CONTRIES') loop
        execute immediate 'ALTER TABLE hr.' || i.table_name || ' enable row movement;';
        execute immediate 'ALTER TABLE hr.' || i.table_name || ' shrink space compact;';
        execute immediate 'ALTER TABLE hr.' || i.table_name || ' shrink space;';
    end loop;
end;
/

exit;
