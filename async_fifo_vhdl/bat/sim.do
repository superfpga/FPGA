vlib work 
vcom -f package.f
vcom -f rtl.f
vsim work.async_fifo_tb
run 3000us 
quit

