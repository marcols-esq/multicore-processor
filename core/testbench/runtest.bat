iverilog -Wanachronisms -Wimplicit -Wimplicit-dimensions -Wmacro-replacement -Wportbind -Wselect-range -Wsensitivity-entire-array -I.. -o %1.out %1_tb.v inst_monitor.v ../*.v
@ if errorlevel 1 exit %errorlevel%

vvp %1.out
@ if errorlevel 1 exit %errorlevel%

gtkwave %1_tb.vcd %1.gtkw
