//-----------------------------------------------------------------------------
// Title         :
// Project       :
//-----------------------------------------------------------------------------
// File          : sync_w2r.v
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



module sync_w2r
  (/*AUTOARG*/
   // Outputs
   rdq2_wrptr,
   // Inputs
   rdclk, reset_n, wrptr
   );
   parameter                  FIFO_ADDR_WIDTH = 8;

   input                      rdclk;
   input                      reset_n;

   input [FIFO_ADDR_WIDTH:0]  wrptr;

   output [FIFO_ADDR_WIDTH:0] rdq2_wrptr;
   reg [FIFO_ADDR_WIDTH:0]    rdq2_wrptr;


   reg [FIFO_ADDR_WIDTH:0]    rdq1_wrptr;


   always @(posedge rdclk or negedge reset_n)
     if (reset_n == 1'b0)
       begin
          rdq2_wrptr <= {FIFO_ADDR_WIDTH+1{1'b0}};
          rdq1_wrptr <= {FIFO_ADDR_WIDTH+1{1'b0}};
       end
     else
       begin
          rdq1_wrptr <= wrptr;
          rdq2_wrptr <= rdq1_wrptr;
       end


endmodule
