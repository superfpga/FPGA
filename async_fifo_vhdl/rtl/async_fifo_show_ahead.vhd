----------------------------------------------------------------------------------
-- Company:  GKHY
-- Engineer: bingyang.wang
--
-- Create Date:    2014-1-7 9:54:54
-- Project Name:   dm_out_top
-- Module Name:    async_fifo_show_ahead - Behavioral
-- Belong Project Name: 0080
-- Test Module Name : none
-- Target Devices:  xq2vp40
-- Tool versions: ISE 10.1.03
-- Description:
--// show ahead synchronous FIFO mode
--// The data became available before 'rdreq' is asserted, 'rdreq' acts as a read request
--
-- Dependencies: none
--
-- Revision: 2.00
-- Revision 1.00 - File Created
----------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;


-- Show-ahead asynchronous FIFO mode
-- The data became available before 'rdreq' IS asserted, 'rdreq' acts as a read acknowledge



ENTITY async_fifo_show_ahead IS
  GENERIC (
    FIFO_DATA_WIDTH	: INTEGER := 32;  -----fifo data width
    FIFO_ADDR_WIDTH	: INTEGER := 8;   -----fifo addr width

    PROG_FULL_THR	: INTEGER := 0;   -----fifo program full threshold
    PROG_EMPTY_THR	: INTEGER := 0    -----fifo program empty threshold
    );

  PORT (
    -- Main Clock AND Reset
    wrclk		: IN STD_LOGIC;  ----write Clock
    rdclk		: IN STD_LOGIC;  ----read Clock
    reset_n		: IN STD_LOGIC;  ----reset negative

    -- Async FIFO Interface
    wrreq		: IN STD_LOGIC;         ----write request
    data		: IN STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0); ---write data
    rdreq		: IN STD_LOGIC;         ----read request
    q			: OUT STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0);---read data
    wrusedw		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);---write domain used
    rdusedw		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);---read domain used
    prog_full	: OUT STD_LOGIC;         ----fifo program full
    prog_empty	: OUT STD_LOGIC;         ----fifo program empty
    wrfull		: OUT STD_LOGIC;         ----fifo full
    rdempty		: OUT STD_LOGIC          ----fifo empty
    );
END ENTITY async_fifo_show_ahead;




ARCHITECTURE behav OF async_fifo_show_ahead IS




  COMPONENT sync_ram_std_dc IS
    GENERIC (
      RAM_DATA_WIDTH	: INTEGER := 32;
      RAM_ADDR_WIDTH	: INTEGER := 8
      );

    PORT (
      -- Main Clock
--		gls_reset_n : IN   STD_LOGIC;
      wrclk		: IN STD_LOGIC;
      rdclk		: IN STD_LOGIC;

      -- dual-port Sync RAM Interface for writting
      wren		: IN STD_LOGIC;
      wraddr		: IN STD_LOGIC_VECTOR(RAM_ADDR_WIDTH - 1 DOWNTO 0);
      data		: IN STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0);
      wr_q		: OUT STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0);

      -- dual-port Sync RAM Interface for reading
      rdaddr		: IN STD_LOGIC_VECTOR(RAM_ADDR_WIDTH - 1 DOWNTO 0);
      q			: OUT STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0)
      );
  END COMPONENT sync_ram_std_dc;




  COMPONENT async_fifo_show_ahead_rd_task_logic IS
    GENERIC (
      FIFO_ADDR_WIDTH	: INTEGER := 8;

      PROG_EMPTY_THR	: INTEGER := 0
      );

    PORT (
      -- Main Read Clock AND Reset#
      rdclk		: IN STD_LOGIC;
      reset_n		: IN STD_LOGIC;

      -- Async FIFO Interface for read
      rdreq		: IN STD_LOGIC;
      rdusedw		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
      prog_empty	: OUT STD_LOGIC;
      rdempty		: OUT STD_LOGIC;

      -- Sync dual-clock RAM Interface for read
      rdaddr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);

      -- read pointer synchronized to write clock domain
      rdptr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);

      -- write pointer synchronized from write clock domain
      rdq2_wrptr	: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)
      );
  END COMPONENT async_fifo_show_ahead_rd_task_logic;




  COMPONENT async_fifo_show_ahead_wr_task_logic IS
    GENERIC (
      FIFO_ADDR_WIDTH	: INTEGER := 8;

      PROG_FULL_THR	: INTEGER := 0
      );

    PORT (
      -- Main Write Clock AND Reset#
      wrclk		: IN STD_LOGIC;
      reset_n		: IN STD_LOGIC;

      -- Async FIFO Interface for write
      wrreq		: IN STD_LOGIC;
      wrusedw		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
      prog_full	: OUT STD_LOGIC;
      wrfull		: OUT STD_LOGIC;

      -- Sync dual-clock RAM Interface for write
      wren		: OUT STD_LOGIC;
      wraddr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);

      -- write pointer synchronized to read clock domain
      wrptr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);

      -- read pointer synchronized from read clock domain
      wrq2_rdptr	: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)
      );
  END COMPONENT async_fifo_show_ahead_wr_task_logic;





  COMPONENT sync_w2r IS
    GENERIC (
      FIFO_ADDR_WIDTH	: INTEGER := 8
      );

    PORT (
      -- Main Read Clock AND Reset#
      rdclk		: IN STD_LOGIC;
      reset_n		: IN STD_LOGIC;

      -- write pointer(gray)
      wrptr		: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);

      -- read pointer synchronized to write clock domain
      rdq2_wrptr	: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)
      );
  END COMPONENT sync_w2r;






  COMPONENT sync_r2w IS
    GENERIC (
      FIFO_ADDR_WIDTH	: INTEGER := 8
      );

    PORT (
      -- Main Write Clock AND Reset#
      wrclk		: IN STD_LOGIC;
      reset_n		: IN STD_LOGIC;

      -- read pointer(gray)
      rdptr		: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);

      -- write pointer synchronized to read clock domain
      wrq2_rdptr	: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)
      );
  END COMPONENT sync_r2w;





--*************************************
--			Signal
--*************************************/
  SIGNAL	wren		: STD_LOGIC;         ----write request

  SIGNAL	wraddr      : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);  ----Write address
  SIGNAL	rdaddr      : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);  ----read  address

  SIGNAL	wrq2_rdptr	: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---Write pointer
  SIGNAL	rdq2_wrptr  : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---read pointer

  SIGNAL	wrptr       : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---Write pointer
  SIGNAL	rdptr       : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---read pointer

----------------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------------


-----------------------------------------------dual port ram
  sync_ram_std_dc_inst : sync_ram_std_dc
    GENERIC MAP (
      RAM_DATA_WIDTH => FIFO_DATA_WIDTH,
      RAM_ADDR_WIDTH => FIFO_ADDR_WIDTH
      )

    PORT MAP (
      -- Main Clock
--		gls_reset_n => reset_n,
      wrclk  => wrclk,
      rdclk  => rdclk,

      -- dual-port Sync RAM Interface for writting
      wren   => wren,
      wraddr => wraddr,
      data   => data,
      wr_q   => open ,

      -- dual-port Sync RAM Interface for reading
      rdaddr => rdaddr,
      q      => q
      );


-----------------------------------------------write Interface
  async_fifo_show_ahead_wr_task_logic_inst : async_fifo_show_ahead_wr_task_logic
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH,
      PROG_FULL_THR   => PROG_FULL_THR
      )

    PORT MAP (
      -- Main Write Clock AND Reset#
      wrclk     => wrclk,
      reset_n   => reset_n,

      -- Async FIFO Interface for write
      wrreq         => wrreq,
      wrusedw       => wrusedw,
      prog_full     => prog_full,
      wrfull        => wrfull,

      -- Sync dual-clock RAM Interface for write
      wren      => wren,
      wraddr        => wraddr,

      -- write pointer synchronized to read clock domain
      wrptr         => wrptr,

      -- read pointer synchronized from read clock domain
      wrq2_rdptr    => wrq2_rdptr
      );



-----------------------------------------------write address to Read Interface
  sync_w2r_inst : sync_w2r
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
      )

    PORT MAP (
      -- Main Read Clock AND Reset#
      rdclk      => rdclk,
      reset_n    => reset_n,

      -- write pointer(gray)
      wrptr      => wrptr,

      -- read pointer synchronized to write clock domain
      rdq2_wrptr => rdq2_wrptr
      );



-----------------------------------------------read Interface
  async_fifo_show_ahead_rd_task_logic_inst : async_fifo_show_ahead_rd_task_logic
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH,
      PROG_EMPTY_THR  => PROG_EMPTY_THR
      )

    PORT MAP (
      -- Main Read Clock AND Reset#
      rdclk     => rdclk,
      reset_n   => reset_n,

      -- Async FIFO Interface for read
      rdreq         => rdreq,
      rdusedw       => rdusedw,
      prog_empty    => prog_empty,
      rdempty       => rdempty,

      -- Sync dual-clock RAM Interface for read
      rdaddr        => rdaddr,

      -- read pointer synchronized to write clock domain
      rdptr         => rdptr,

      -- write pointer synchronized from write clock domain
      rdq2_wrptr    => rdq2_wrptr
      );




-----------------------------------------------Read address to write Interface
  sync_r2w_inst : sync_r2w
    GENERIC MAP (
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
      )

    PORT MAP (
      -- Main Write Clock AND Reset#
      wrclk      => wrclk,
      reset_n    => reset_n,

      -- read pointer(gray)
      rdptr      => rdptr,

      -- write pointer synchronized to read clock domain
      wrq2_rdptr => wrq2_rdptr
      );





----------------------------------------------------------------------------------------
END ARCHITECTURE behav;
