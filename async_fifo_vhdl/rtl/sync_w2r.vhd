----------------------------------------------------------------------------------
-- Company:  GKHY
-- Engineer: bingyang.wang
--
-- Create Date:    2014-1-7 9:54:54
-- Project Name:   dm_out_top
-- Module Name:    sync_w2r - Behavioral
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



ENTITY sync_w2r IS
    GENERIC (
        FIFO_ADDR_WIDTH	: INTEGER := 8    -----fifo addr width
    );

    PORT (
        -- Main Read Clock AND Reset#
        rdclk		: IN STD_LOGIC;   ----read clock
        reset_n		: IN STD_LOGIC;   --- Async RESET#

        -- write pointer(gray)
        wrptr		: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ------write pointer

        -- read pointer synchronized to write clock domain
        rdq2_wrptr	: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)  ------write pointer to Read clock domain
    );
END ENTITY sync_w2r;





ARCHITECTURE arch_sync_w2r OF sync_w2r IS


--*************************************
--			Signal
--*************************************
SIGNAL	rdq1_wrptr	: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ------write pointer



BEGIN
----------------------------------------------------------------------------------------
-----------synchronized
----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdq2_wrptr <= (OTHERS => '0');
        rdq1_wrptr <= (OTHERS => '0');
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        rdq1_wrptr <= wrptr;
        rdq2_wrptr <= rdq1_wrptr;
    END IF;
END PROCESS;



END ARCHITECTURE arch_sync_w2r;