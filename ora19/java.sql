set echo on

DECLARE
i NUMBER;
v_sql VARCHAR2(200);
BEGIN
  FOR i IN 1..200 LOOP
    -- Build up a dynamic statement to create a uniquely named java stored proc.
    -- The "chr(10)" is there to put a CR/LF in the source code.
    v_sql := 'create or replace and compile' || chr(10) ||
             'java source named "SmallJavaProc' || i || '"'  || chr(10) ||
             'as' || chr(10) ||
             'import java.lang.*;' || chr(10) ||
             'public class Util' || i || ' extends Object' || chr(10) ||
             '{ int v1=1;int v2=2;int v3=3;int v4=4;int v5=5;int v6=6;int v7=7; }';
    EXECUTE IMMEDIATE v_sql;
  END LOOP;
END;
/

