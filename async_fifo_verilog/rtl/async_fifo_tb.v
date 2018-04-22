//-----------------------------------------------------------------------------
// Title         :
// Project       : fifo
//-----------------------------------------------------------------------------
// File          : async_fifo_tb.v
// Author        : changhui.liu
// Created       : 17.03.2018
// Last modified : 17.03.2018
//-----------------------------------------------------------------------------
// Description :
//
//-----------------------------------------------------------------------------
// Copyright (c) 2018 by AVIC This model is the confidential and
// proprietary property of AVIC and the possession or use of this
// file requires a written license from AVIC.
//------------------------------------------------------------------------------
// Modification history :
// 17.03.2018 : created
//-----------------------------------------------------------------------------



module async_fifo_tb;
   parameter                  FIFO_DATA_WIDTH = 32;
   parameter                  FIFO_ADDR_WIDTH = 8;

   parameter                  PROG_FULL_THR = 8;
   parameter                  PROG_EMPTY_THR = 8;


   wire                       wrclk;
   wire                       rdclk;
   wire                       reset_n;
   reg                        wrreq;
   reg [FIFO_DATA_WIDTH-1:0]  data_internal;
   wire [FIFO_DATA_WIDTH-1:0] data;
   wire                       rdreq;
   wire [FIFO_DATA_WIDTH-1:0] q;
   wire [FIFO_ADDR_WIDTH-1:0] wrusedw;
   wire [FIFO_ADDR_WIDTH-1:0] rdusedw;
   wire                       prog_full;
   wire                       prog_empty;
   wire                       wrfull;
   wire                       rdempty;

   reg                        sys_rst_n;
   reg                        sys_clk;
   reg                        sys_rd_clk;

   parameter                  sys_clk_period = 40;
   parameter                  sys_rd_clk_period = 40;

   assign wrclk = sys_clk;
   assign rdclk = sys_rd_clk;
   assign reset_n = sys_rst_n;
   assign rdreq = (prog_empty == 1'b0) ? 1'b1 :  1'b0;


   always @(posedge sys_clk or negedge sys_rst_n)
     if (sys_rst_n == 1'b0)
       wrreq <= 1'b0;
     else
       begin
          if (wrfull == 1'b0)
            wrreq <= 1'b1;
          else
            wrreq <= 1'b0;
       end


   always @(posedge sys_clk or negedge sys_rst_n)
     if (sys_rst_n == 1'b0)
       data_internal <= {FIFO_DATA_WIDTH{1'b1}};
     else
       begin
          if (wrreq == 1'b1)
            data_internal <= data_internal - 1;
       end

     assign data = data_internal;


     async_fifo_show_ahead
       #(/*AUTOINSTPARAM*/
         // Parameters
         .FIFO_DATA_WIDTH               (FIFO_DATA_WIDTH),
         .FIFO_ADDR_WIDTH               (FIFO_ADDR_WIDTH),
         .PROG_FULL_THR                 (PROG_FULL_THR),
         .PROG_EMPTY_THR                (PROG_EMPTY_THR))
     async_fifo_show_ahead_1
       (/*AUTOINST*/
        // Outputs
        .q                              (q[FIFO_DATA_WIDTH-1:0]),
        .wrusedw                        (wrusedw[FIFO_ADDR_WIDTH-1:0]),
        .rdusedw                        (rdusedw[FIFO_ADDR_WIDTH-1:0]),
        .prog_full                      (prog_full),
        .prog_empty                     (prog_empty),
        .wrfull                         (wrfull),
        .rdempty                        (rdempty),
        // Inputs
        .wrclk                          (wrclk),
        .rdclk                          (rdclk),
        .reset_n                        (reset_n),
        .wrreq                          (wrreq),
        .data                           (data[FIFO_DATA_WIDTH-1:0]),
        .rdreq                          (rdreq));


     always
       begin: sys_clk_process
          sys_clk <= 1'b0;
          #(sys_clk_period/2);
          sys_clk <= 1'b1;
          #(sys_clk_period/2);
       end


   always
     begin: sys_rd_clk_process
        sys_rd_clk <= 1'b0;
        #(sys_rd_clk_period/2);
        sys_rd_clk <= 1'b1;
        #(sys_rd_clk_period/2);
     end


   initial
     begin: stim_proc
        sys_rst_n <= 1'b0;
        #(95);
        sys_rst_n <= 1'b1;

     end


   initial
     begin
        $fsdbDumpfile("debussy.fsdb");
        $fsdbDumpvars(0,"async_fifo_tb");
     end

endmodule
