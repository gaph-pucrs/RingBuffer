# RingBuffer

RingBuffer SystemVerilog module.

## About

This module is a simple ringbuffer.
`DATA_SIZE` controls the buffer width, which can be any number >0.
`BUFFER_SIZE` controls the buffer depth, which needs to be power of 2.
`tx_o` signal is high while the buffer is not empty.
`rx_ack_o` signal is high while the buffer is not full.
