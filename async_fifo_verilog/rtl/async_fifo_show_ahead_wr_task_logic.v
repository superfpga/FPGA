//-----------------------------------------------------------------------------
// Title         : verilog
// Project       : fifo
//-----------------------------------------------------------------------------
// File          : async_fifo_show_ahead_wr_task_logic.v
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



module async_fifo_show_ahead_wr_task_logic(wrclk, reset_n, wrreq, wrusedw, prog_full, wrfull, wren, wraddr, wrptr, wrq2_rdptr);
   parameter                    FIFO_ADDR_WIDTH = 8;

   parameter                    PROG_FULL_THR = 0;

   input                        wrclk;
   input                        reset_n;

   input                        wrreq;
   output [FIFO_ADDR_WIDTH-1:0] wrusedw;
   output                       prog_full;
   output                       wrfull;

   output                       wren;
   output [FIFO_ADDR_WIDTH-1:0] wraddr;

   output [FIFO_ADDR_WIDTH:0]   wrptr;
   reg [FIFO_ADDR_WIDTH:0]      wrptr;

   input [FIFO_ADDR_WIDTH:0]    wrq2_rdptr;


   parameter                    FIFO_DATA_WIDTH = FIFO_ADDR_WIDTH + 1;

   function [FIFO_DATA_WIDTH-1:0] func_wr_bin_to_gray_conv;
      input [FIFO_DATA_WIDTH-1:0]       binary;

      reg [FIFO_DATA_WIDTH-1:0]         bin_to_gray_conv;
   begin
      bin_to_gray_conv = {9{{1'b0, binary[FIFO_DATA_WIDTH - 1:1]}}} ^ binary;
      //bin_to_gray_conv = (binary>>1) ^ binary;

      func_wr_bin_to_gray_conv = (bin_to_gray_conv);
   end
   endfunction

   function [FIFO_DATA_WIDTH-1:0] func_wr_gray_to_bin_conv;
      input [FIFO_DATA_WIDTH-1:0]       gray;

      integer                      i;
      reg [FIFO_DATA_WIDTH-1:0]         gray_to_bin_conv;
   begin
      gray_to_bin_conv[FIFO_DATA_WIDTH - 1] = gray[FIFO_DATA_WIDTH - 1];

      i = FIFO_DATA_WIDTH - 2;

      while (i >= 0)
      begin
         gray_to_bin_conv[i] = gray_to_bin_conv[i + 1] ^ gray[i];
         i = i - 1;
      end

      func_wr_gray_to_bin_conv = (gray_to_bin_conv);
   end
   endfunction

   reg [FIFO_ADDR_WIDTH:0]      wrbin;

   reg [FIFO_ADDR_WIDTH:0]      wrusedw_r0;
   wire [FIFO_ADDR_WIDTH:0]     wrusedw_r1;
   reg [FIFO_ADDR_WIDTH+1:0]    wrusedw_r1_r;
   reg [FIFO_ADDR_WIDTH-1:0]    wrusedw_r;
   reg                          wrusedw_sw;

   reg                          prog_full_r;

   reg [FIFO_ADDR_WIDTH:0]      rdptr_bin_r;

   reg                          wrfull_r;

   wire                         wren_r;

   wire                         wrfull_val;

   wire [FIFO_ADDR_WIDTH:0]     rdptr_bin;

   wire [FIFO_ADDR_WIDTH:0]     wrusedw_i;

   wire [FIFO_ADDR_WIDTH:0]     wrgray;
   wire [FIFO_ADDR_WIDTH:0]     wbinnext;

   assign wraddr = wrbin[FIFO_ADDR_WIDTH - 1:0];


   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
      begin
         wrbin <= {FIFO_ADDR_WIDTH+1{1'b0}};

         wrptr <= {FIFO_ADDR_WIDTH+1{1'b0}};
      end
      else
      begin
         wrbin <= wbinnext;

         wrptr <= wrgray;
      end

   assign wbinnext = wrbin + wren_r;

   assign wrfull_val = ((wrgray == ({((~wrq2_rdptr[FIFO_ADDR_WIDTH:FIFO_ADDR_WIDTH - 1])), wrq2_rdptr[FIFO_ADDR_WIDTH - 2:0]}))) ? 1'b1 :
                       1'b0;

   assign wrgray = func_wr_bin_to_gray_conv(wbinnext);

   assign wrfull = wrfull_r;

   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         wrfull_r <= 1'b0;
      else
         wrfull_r <= wrfull_val;

   assign wrusedw = wrusedw_r;

   assign rdptr_bin = func_wr_gray_to_bin_conv(wrq2_rdptr);


   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         rdptr_bin_r <= {FIFO_ADDR_WIDTH+1{1'b0}};
      else
         rdptr_bin_r <= rdptr_bin;


   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         wrusedw_r0 <= {FIFO_ADDR_WIDTH+1{1'b0}};
      else
         wrusedw_r0 <= wrbin - rdptr_bin_r;

   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         wrusedw_r1_r <= {FIFO_ADDR_WIDTH+2{1'b0}};
      else
         wrusedw_r1_r <= ({1'b1, wrbin}) - ({1'b0, rdptr_bin_r});

   assign wrusedw_r1 = wrusedw_r1_r[FIFO_ADDR_WIDTH:0];

   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         wrusedw_sw <= 1'b0;
      else
      begin
         if (wrbin < rdptr_bin_r)
            wrusedw_sw <= 1'b1;
         else
            wrusedw_sw <= 1'b0;
      end

   assign wrusedw_i = ((wrusedw_sw == 1'b0)) ? wrusedw_r0 :
                      wrusedw_r1;


   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         wrusedw_r <= {FIFO_ADDR_WIDTH{1'b0}};
      else
         wrusedw_r <= wrusedw_i[FIFO_ADDR_WIDTH - 1:0];

   assign prog_full = prog_full_r;

   always @(posedge wrclk or negedge reset_n)
      if (reset_n == 1'b0)
         prog_full_r <= 1'b0;
      else
      begin
         if (wrusedw_i >= PROG_FULL_THR)
            prog_full_r <= 1'b1;
         else
            prog_full_r <= 1'b0;
      end

   assign wren_r = wrreq & ((~wrfull_r));

   assign wren = wren_r;

endmodule
