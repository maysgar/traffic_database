set serveroutput on;
set timing on;
set autotrace on;

@'\\tsclient\C\Users\NitroPC\Desktop\creation.sql'
@'\\tsclient\C\Users\NitroPC\Desktop\solution.sql'
@'\\tsclient\C\Users\NitroPC\Desktop\script_statistics.sql'
@'\\tsclient\C\Users\NitroPC\Desktop\insert.sql'

begin
pkg_costes.run_test;
end;
/
