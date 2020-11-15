onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib InsMem_opt

do {wave.do}

view wave
view structure
view signals

do {InsMem.udo}

run -all

quit -force
