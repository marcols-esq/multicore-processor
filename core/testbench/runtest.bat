SET name=%1
IF "%name%"=="" SET name=test1

iverilog -Wanachronisms -Wimplicit -Wimplicit-dimensions -Wmacro-replacement -Wportbind -Wselect-range -Wsensitivity-entire-array -I.. -o %name%.out %name%_tb.v inst_monitor.v ../*.v
@ if errorlevel 1 exit %errorlevel%

vvp %name%.out
@ if errorlevel 1 exit %errorlevel%

gtkwave %name%_tb.vcd %name%.gtkw
