vlib work 
vlog -f rtl.f 
vsim -novopt work.async_fifo_tb
run 3000us 
quit

