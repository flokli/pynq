set pagination off
target extended-remote :3333
monitor halt
file ./start_pynq.pbl
load
layout asm
layout src
layout split
