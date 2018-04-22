----------------------------------------------------------------------------------
-- Company:  GKHY
-- Engineer: bingyang.wang 
-- 
-- Create Date:    2014-1-7 9:54:54
-- Project Name:   dm_out_top
-- Module Name:    sync_r2w - Behavioral 
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



ENTITY sync_r2w IS
	GENERIC (	
		FIFO_ADDR_WIDTH	: INTEGER := 8    -----fifo addr width
	);
	
	PORT (
		-- Main Write Clock AND Reset#
		wrclk		: IN STD_LOGIC;  ----write Clock
		reset_n		: IN STD_LOGIC;  --- Async RESET#

		-- read pointer(gray)
		rdptr		: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ------read pointer

		-- write pointer synchronized to read clock domain
		wrq2_rdptr	: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)   ------read pointer to write clock domain
	);
END ENTITY sync_r2w;





ARCHITECTURE arch_sync_r2w OF sync_r2w IS


--*************************************
--			Signal
--*************************************
SIGNAL	wrq1_rdptr	: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ------read pointer



BEGIN



----------------------------------------------------------------------------------------
-----------synchronized
----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
	IF (reset_n = '0') THEN
		wrq2_rdptr <= (OTHERS => '0');
		wrq1_rdptr <= (OTHERS => '0');
	ELSIF (wrclk'EVENT AND wrclk = '1') THEN	
		wrq1_rdptr <= rdptr;
		wrq2_rdptr <= wrq1_rdptr;
	END IF;
END PROCESS;



END ARCHITECTURE arch_sync_r2w;