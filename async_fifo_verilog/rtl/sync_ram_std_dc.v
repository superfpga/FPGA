//-----------------------------------------------------------------------------
// Title         : verilog file
// Project       : fifo
//-----------------------------------------------------------------------------
// File          : sync_ram_std_dc.v
// Author        : changhui.liu
// Created       : 04.03.2018
// Last modified : 04.03.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by AVIC This model is the confidential and
// proprietary property of AVIC and the possession or use of this
// file requires a written license from AVIC.
//------------------------------------------------------------------------------
// Modification history :
// 04.03.2018 : created
//-----------------------------------------------------------------------------



module sync_ram_std_dc
  (/*AUTOARG*/
   // Outputs
   wr_q, q,
   // Inputs
   wrclk, rdclk, wren, wraddr, data, rdaddr
   );
   parameter                   FIFO_DATA_WIDTH = 32;
   parameter                   FIFO_ADDR_WIDTH = 8;

   input                       wrclk;
   input                       rdclk;

   input                       wren;
   input [FIFO_ADDR_WIDTH-1:0]  wraddr;
   input [FIFO_DATA_WIDTH-1:0]  data;
   output [FIFO_DATA_WIDTH-1:0] wr_q;
   reg [FIFO_DATA_WIDTH-1:0]    wr_q;

   input [FIFO_ADDR_WIDTH-1:0]  rdaddr;
   output [FIFO_DATA_WIDTH-1:0] q;
   reg [FIFO_DATA_WIDTH-1:0]    q;



   reg [FIFO_DATA_WIDTH-1:0]    ram_block[2**FIFO_ADDR_WIDTH-1:0];

   always @(posedge wrclk)

     begin
        if (wren == 1'b1)
          ram_block[wraddr] <= data;
        wr_q <= ram_block[wraddr];
     end

   always @(posedge rdclk)

     q <= ram_block[rdaddr];

endmodule
