/**
 * RingBuffer
 * @file RingBuffer.sv
 *
 * @author Angelo Elias Dal Zotto (angelo.dalzotto@edu.pucrs.br)
 * GAPH - Hardware Design Support Group (https://corfu.pucrs.br)
 * PUCRS - Pontifical Catholic University of Rio Grande do Sul (http://pucrs.br/)
 *
 * @date October 2023
 *
 * @brief RingBuffer module
 */

module RingBuffer
#(
    parameter DATA_SIZE = 32,
    parameter BUFFER_SIZE = 8   /* Power of 2 */
)
(
    input  logic                     clk_i,
    input  logic                     rst_ni,

    input  logic                     rx_i,
    output logic                     rx_ack_o,
    input  logic [(DATA_SIZE - 1):0] data_i,

    output logic                     tx_o,
    input  logic                     tx_ack_i,
    output logic [(DATA_SIZE - 1):0] data_o
);

    logic full;
    logic empty;

    logic [($clog2(BUFFER_SIZE) - 1):0] head;
    logic [($clog2(BUFFER_SIZE) - 1):0] tail;

    logic [($clog2(BUFFER_SIZE) - 1):0] next_head;
    logic [($clog2(BUFFER_SIZE) - 1):0] next_tail;

    logic [(DATA_SIZE - 1):0]           buffer [(BUFFER_SIZE - 1):0];

    assign rx_ack_o = !full;
    assign tx_o     = !empty;
    assign data_o   = buffer[tail];

    assign next_head = head + 1'b1;
    assign next_tail = tail + 1'b1;

    logic can_receive;
    assign can_receive = rx_i && !full;

    logic can_send;
    assign can_send = tx_ack_i && !empty;

    /* Buffer write control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (rst_ni)
            if (can_receive)
                buffer[head] <= data_i;
    end

    /* Head control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            head <= '0;
        else
            if (can_receive)
                head <= next_head;
    end

    /* Tail control */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni)
            tail <= '0;
        else
            if (can_send)
                tail <= next_tail;
    end

    /* Input control: sets full when next_head == tail on an insertion */
    /* Output control: sets empty when next_tail == head on a removal */
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            full  <= 1'b0;
            empty <= 1'b1;
        end
        else begin
            if (can_receive) begin
                if (!can_send)
                    full <= next_head == tail;

                empty <= 1'b0;
            end

            if (can_send) begin
                if (!can_receive)
                    empty <= next_tail == head;

                full <= 1'b0;
            end
        end
    end

endmodule
