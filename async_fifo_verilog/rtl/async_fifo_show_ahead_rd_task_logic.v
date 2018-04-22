//-----------------------------------------------------------------------------
// Title         :
// Project       : fifo
//-----------------------------------------------------------------------------
// File          : async_fifo_show_ahead_rd_task_logic.v
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

module async_fifo_show_ahead_rd_task_logic(/*AUTOARG*/
                                           // Outputs
                                           rdusedw, prog_empty, rdempty, rdaddr, rdptr,
                                           // Inputs
                                           rdclk, reset_n, rdreq, rdq2_wrptr
                                           );
   parameter                    FIFO_ADDR_WIDTH = 8;

   parameter                    PROG_EMPTY_THR = 0;

   input                        rdclk;
   input                        reset_n;

   input                        rdreq;
   output [FIFO_ADDR_WIDTH-1:0] rdusedw;
   output                       prog_empty;
   output                       rdempty;

   output [FIFO_ADDR_WIDTH-1:0] rdaddr;

   output [FIFO_ADDR_WIDTH:0]   rdptr;
   reg [FIFO_ADDR_WIDTH:0]      rdptr;

   input [FIFO_ADDR_WIDTH:0]    rdq2_wrptr;


   parameter                    FIFO_DATA_WIDTH = FIFO_ADDR_WIDTH + 1;

   function [FIFO_DATA_WIDTH-1:0] func_rd_bin_to_gray_conv;
      input [FIFO_DATA_WIDTH-1:0]    binary;

      reg [FIFO_DATA_WIDTH-1:0]      bin_to_gray_conv;
      begin
         bin_to_gray_conv = {9{{1'b0, binary[FIFO_DATA_WIDTH - 1:1]}}} ^ binary;

         func_rd_bin_to_gray_conv = (bin_to_gray_conv);
      end
   endfunction

   function [FIFO_DATA_WIDTH-1:0] func_rd_gray_to_bin_conv;
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

         func_rd_gray_to_bin_conv = (gray_to_bin_conv);
      end
   endfunction

   reg [FIFO_ADDR_WIDTH:0]      rdbin;

   reg [FIFO_ADDR_WIDTH:0]      rdusedw_r0;
   wire [FIFO_ADDR_WIDTH:0]     rdusedw_r1;
   reg [FIFO_ADDR_WIDTH+1:0]    rdusedw_r1_r;
   reg [FIFO_ADDR_WIDTH-1:0]    rdusedw_r;
   reg                          rdusedw_sw;

   reg                          prog_empty_r;

   reg [FIFO_ADDR_WIDTH:0]      wrptr_bin_r;

   reg                          rdempty_r;

   wire                         rdempty_val;

   wire [FIFO_ADDR_WIDTH:0]     wrptr_bin;

   wire [FIFO_ADDR_WIDTH:0]     rdusedw_i;

   wire [FIFO_ADDR_WIDTH:0]     rdgray;
   wire [FIFO_ADDR_WIDTH:0]     rdbinnext;

   wire                         rden;

   assign rdaddr = rdbinnext[FIFO_ADDR_WIDTH - 1:0];

   always @(posedge rdclk or negedge reset_n)
     if (reset_n == 1'b0)
       begin
          rdbin <= {FIFO_ADDR_WIDTH+1{1'b0}};

     rdptr <= {FIFO_ADDR_WIDTH+1{1'b0}};
  end
     else
       begin
          rdbin <= rdbinnext;

          rdptr <= rdgray;
       end

   assign rdbinnext = rdbin + rden;

   assign rdempty_val = ((rdgray == rdq2_wrptr)) ? 1'b1 :
                        1'b0;

   assign rdgray = func_rd_bin_to_gray_conv(rdbinnext);

   assign rdempty = rdempty_r;

   always @(posedge rdclk or negedge reset_n)
     if (reset_n == 1'b0)
       rdempty_r <= 1'b1;
     else
       rdempty_r       <= rdempty_val;

   assign rdusedw = rdusedw_r;

   assign wrptr_bin = func_rd_gray_to_bin_conv(rdq2_wrptr);


   always @(posedge rdclk or negedge reset_n)
     if (reset_n == 1'b0)
       wrptr_bin_r <= {FIFO_ADDR_WIDTH+1{1'b0}};
     else
       wrptr_bin_r <= wrptr_bin;


     always @(posedge rdclk or negedge reset_n)
       if (reset_n == 1'b0)
         rdusedw_r0 <= {FIFO_ADDR_WIDTH+1{1'b0}};
       else
         rdusedw_r0 <= wrptr_bin_r - rdbin;


       always @(posedge rdclk or negedge reset_n)
         if (reset_n == 1'b0)
           rdusedw_r1_r <= {FIFO_ADDR_WIDTH+2{1'b0}};
         else
           rdusedw_r1_r <= ({1'b1, wrptr_bin_r}) - ({1'b0, rdbin});

         assign rdusedw_r1 = rdusedw_r1_r[FIFO_ADDR_WIDTH:0];


         always @(posedge rdclk or negedge reset_n)
           if (reset_n == 1'b0)
             rdusedw_sw <= 1'b0;
           else
             begin
                if (wrptr_bin_r < rdbin)
                  rdusedw_sw <= 1'b1;
                else
                  rdusedw_sw <= 1'b0;
             end

   assign rdusedw_i = ((rdusedw_sw == 1'b0)) ? rdusedw_r0 :
                      rdusedw_r1;


   always @(posedge rdclk or negedge reset_n)
     if (reset_n == 1'b0)
       rdusedw_r <= {FIFO_ADDR_WIDTH{1'b0}};
     else
       rdusedw_r <= rdusedw_i[FIFO_ADDR_WIDTH - 1:0];

     assign prog_empty = prog_empty_r;

     always @(posedge rdclk or negedge reset_n)
       if (reset_n == 1'b0)
         prog_empty_r <= 1'b1;
       else
         begin
            if (rdusedw_i < PROG_EMPTY_THR)
              prog_empty_r <= 1'b1;
            else
              prog_empty_r <= 1'b0;
         end

   assign rden = rdreq & ((~rdempty_r));

endmodule
