//-----------------------------------------------------------------------------
// Title         :
// Project       : fifo
//-----------------------------------------------------------------------------
// File          : sync_r2w.v
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




module sync_r2w
  (/*AUTOARG*/
   // Outputs
   wrq2_rdptr,
   // Inputs
   wrclk, reset_n, rdptr
   );
   parameter                  FIFO_ADDR_WIDTH = 8;

   input                      wrclk;
   input                      reset_n;

   input [FIFO_ADDR_WIDTH:0]  rdptr;

   output [FIFO_ADDR_WIDTH:0] wrq2_rdptr;
   reg [FIFO_ADDR_WIDTH:0]    wrq2_rdptr;


   reg [FIFO_ADDR_WIDTH:0]    wrq1_rdptr;


   always @(posedge wrclk or negedge reset_n)
     if (reset_n == 1'b0)
       begin
          wrq1_rdptr <= {FIFO_ADDR_WIDTH+1{1'b0}};
          wrq2_rdptr <= {FIFO_ADDR_WIDTH+1{1'b0}};
       end
     else
       begin
          wrq1_rdptr <= rdptr;
          wrq2_rdptr <= wrq1_rdptr;
       end

endmodule
