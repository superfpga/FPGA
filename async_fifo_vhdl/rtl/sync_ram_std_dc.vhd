----------------------------------------------------------------------------------
-- Company:  GKHY
-- Engineer: bingyang.wang
--
-- Create Date:    2014-1-7 9:54:54
-- Project Name:   dm_out_top
-- Module Name:    sync_ram_std_dc - Behavioral
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
USE ieee.std_logic_unsigned.all;

ENTITY sync_ram_std_dc IS
  GENERIC (
    RAM_DATA_WIDTH	: INTEGER := 32;  -----fifo data width
    RAM_ADDR_WIDTH	: INTEGER := 8    -----fifo addr width
    );

  PORT (
    -- Main Clock
--		gls_reset_n : IN   STD_LOGIC;
    wrclk		: IN STD_LOGIC;  ----write Clock
    rdclk		: IN STD_LOGIC;  ----read Clock

    -- dual-port Sync RAM Interface for writting
    wren		: IN STD_LOGIC;         ----write request
    wraddr	: IN STD_LOGIC_VECTOR(RAM_ADDR_WIDTH - 1 DOWNTO 0);         ----write address
    data		: IN  STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0);    ----write data
    wr_q		: OUT STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0);    ----read data

    -- dual-port Sync RAM Interface for reading
    rdaddr		: IN STD_LOGIC_VECTOR(RAM_ADDR_WIDTH - 1 DOWNTO 0);    ----read address
    q			: OUT STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0)    ----read data
    );
END ENTITY sync_ram_std_dc;

ARCHITECTURE arch_sync_ram_std_dc OF sync_ram_std_dc IS

-- registers
  TYPE    MEM	IS array (2 ** RAM_ADDR_WIDTH - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(RAM_DATA_WIDTH - 1 DOWNTO 0);

  SIGNAL	ram_block : MEM;  ----memory
--attribute RAM_STYLE : string;
--attribute RAM_STYLE of ram_block: signal is "BLOCK";
----------------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------------
----- write Interface
----------------------------------------------------------------------------------------
  PROCESS(wrclk)--,gls_reset_n)
  BEGIN
--	IF(gls_reset_n='0') THEN
--		wr_q <= (OTHERS=>'0');
    IF (wrclk'EVENT AND wrclk = '1') THEN
      IF (wren = '1') THEN
        ram_block(conv_integer(wraddr)) <= data;
      END IF;
      wr_q <= ram_block(conv_integer(wraddr));
    END IF;
  END PROCESS;
----------------------------------------------------------------------------------------
-----------read Interface
----------------------------------------------------------------------------------------
  PROCESS(rdclk)--,gls_reset_n)
  BEGIN
--	IF(gls_reset_n='0') THEN
--		q <= (OTHERS=>'0');
    IF (rdclk'EVENT AND rdclk = '1') THEN
      q <= ram_block(conv_integer(rdaddr));
    END IF;
  END PROCESS;
----------------------------------------------------------------------------------------
END ARCHITECTURE arch_sync_ram_std_dc;