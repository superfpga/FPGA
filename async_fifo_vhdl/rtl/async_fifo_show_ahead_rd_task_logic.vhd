----------------------------------------------------------------------------------
-- Company:  GKHY
-- Engineer: bingyang.wang
--
-- Create Date:    2014-1-7 9:54:54
-- Project Name:   dm_out_top
-- Module Name:    async_fifo_show_ahead_rd_task_logic - Behavioral
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




ENTITY async_fifo_show_ahead_rd_task_logic IS
    GENERIC (
        FIFO_ADDR_WIDTH	: INTEGER := 8;  -----fifo addr width

        PROG_EMPTY_THR	: INTEGER := 0   -----fifo program empty threshold
    );

    PORT (
        -- Main Read Clock AND Reset#
        rdclk		: IN STD_LOGIC;  --- aSync Clock for Read
        reset_n		: IN STD_LOGIC;  --- Async RESET#

        -- Async FIFO Interface for read
        rdreq		: IN STD_LOGIC;  --  read request
        rdusedw		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0); --- fifo data words
        prog_empty	: OUT STD_LOGIC;  -- programmable empty flag(Assert when usedw is less than PROG_EMPTY_THR)
        rdempty		: OUT STD_LOGIC;  -- empty flag

        -- Sync dual-clock RAM Interface for read
        rdaddr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);  -- read address

        -- read pointer synchronized to write clock domain
        rdptr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  -- read pointer

        -- write pointer synchronized from write clock domain
        rdq2_wrptr	: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)  -- read address to write pointer
    );
END ENTITY async_fifo_show_ahead_rd_task_logic;






ARCHITECTURE arch_async_fifo_show_ahead_rd_task_logic OF async_fifo_show_ahead_rd_task_logic IS





--*************************************
--			Constant
--*************************************
CONSTANT  DATA_WIDTH	: INTEGER := FIFO_ADDR_WIDTH + 1;



--******************************************************************
--				Function: Binary to Gray Conversion
--*****************************************************************/
function func_rd_bin_to_gray_conv (
    binary	: IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)) return STD_LOGIC_VECTOR IS

        variable bin_to_gray_conv	: STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);       ----Binary to Gray Conversion
    BEGIN
        bin_to_gray_conv := '0' & binary(DATA_WIDTH - 1 DOWNTO 1) xor binary;

        return (bin_to_gray_conv);
END function func_rd_bin_to_gray_conv;



--******************************************************************
--				Function: Gray to Binary Conversion
--*****************************************************************/
function func_rd_gray_to_bin_conv (
    gray	: IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)) return STD_LOGIC_VECTOR IS

        variable i                  :  INTEGER;     ----for circulate
        variable gray_to_bin_conv	: STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);      -----Gray to Binary Conversion
    BEGIN
        gray_to_bin_conv(DATA_WIDTH - 1) := gray(DATA_WIDTH - 1);

        i := DATA_WIDTH - 2;

        while (i >= 0) loop
            gray_to_bin_conv(i) := gray_to_bin_conv(i + 1) xor gray(i);
            i := i - 1;
        END loop;

        return (gray_to_bin_conv);
END function func_rd_gray_to_bin_conv;






--*************************************
--			Signal
--*************************************
SIGNAL	rdbin           : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ---read Binary

SIGNAL	rdusedw_r0		: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ---read usedw register
SIGNAL	rdusedw_r1		: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ---read usedw register
SIGNAL	rdusedw_r1_r	: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH + 1 DOWNTO 0);   ---read usedw register
SIGNAL	rdusedw_r		: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);   ---read usedw register
SIGNAL	rdusedw_sw		: STD_LOGIC;   ---read usedw switch

SIGNAL	prog_empty_r	: STD_LOGIC;   -----fifo program empty register

SIGNAL	wrptr_bin_r		: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---write pointer register

SIGNAL	rdempty_r		: STD_LOGIC;  ----Read empty register

SIGNAL	rdempty_val		: STD_LOGIC;  ----Read empty register

SIGNAL	wrptr_bin		: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---write pointer Binary

SIGNAL	rdusedw_i		: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---Read usedw input

SIGNAL	rdgray          : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---Read gray code
SIGNAL	rdbinnext       : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---Read Binary next

SIGNAL	rden			: STD_LOGIC;  ---Read request



BEGIN




--************************ generate read address, gray style 2 *******************************
rdaddr <= rdbinnext(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdbin <= (OTHERS => '0');

        rdptr <= (OTHERS => '0');
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        rdbin <= rdbinnext;			-- read pointer(binary)

        rdptr <= rdgray;			-- read pointer(gray)
    END IF;
END PROCESS;


rdbinnext <= rdbin + rden;





--************************ generate read empty *******************************
rdempty_val <= '1' WHEN (rdgray = rdq2_wrptr) ELSE
               '0';

-- binary convert to gray
--assign rdgray = {1'b0, rdbinnext[FIFO_ADDR_WIDTH:1]} ^ rdbinnext;
rdgray <= func_rd_bin_to_gray_conv(rdbinnext);


-- generate read empty flag
rdempty <= rdempty_r;
----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdempty_r <= '1';
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        rdempty_r <= rdempty_val;
    END IF;
END PROCESS;






--************************ generate rdusedw *********************************
rdusedw <= rdusedw_r;

-- gray convert to binary
wrptr_bin <= func_rd_gray_to_bin_conv(rdq2_wrptr);

----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrptr_bin_r <= (OTHERS => '0');
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        wrptr_bin_r <= wrptr_bin;
    END IF;
END PROCESS;

----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdusedw_r0 <= (OTHERS => '0');
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        rdusedw_r0 <= wrptr_bin_r - rdbin;
    END IF;
END PROCESS;

----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdusedw_r1_r <= (OTHERS => '0');
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        --rdusedw_r1_r <= 2**(FIFO_ADDR_WIDTH+1) - rdbin + wrptr_bin_r;
        rdusedw_r1_r <= ('1' & wrptr_bin_r) - ('0' & rdbin);
    END IF;
END PROCESS;

rdusedw_r1 <= rdusedw_r1_r(FIFO_ADDR_WIDTH DOWNTO 0);

----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdusedw_sw <= '0';
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        IF (wrptr_bin_r < rdbin) THEN
            rdusedw_sw <= '1';
        ELSE
            rdusedw_sw <= '0';
        END IF;
    END IF;
END PROCESS;


rdusedw_i <= rdusedw_r0 WHEN (rdusedw_sw = '0') ELSE
             rdusedw_r1;

----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdusedw_r <= (OTHERS => '0');
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        rdusedw_r <= rdusedw_i(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
    END IF;
END PROCESS;






--************************ generate prog empty *********************************
prog_empty <= prog_empty_r;
----------------------------------------------------------------------------------------
PROCESS(rdclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        prog_empty_r <= '1';
    ELSIF (rdclk'EVENT AND rdclk = '1') THEN
        IF (rdusedw_i < PROG_EMPTY_THR) THEN
            prog_empty_r <= '1';
        ELSE
            prog_empty_r <= '0';
        END IF;
    END IF;
END PROCESS;



-- read enable for synchronous dual-clock ram
rden <= rdreq AND (NOT rdempty_r);




END ARCHITECTURE arch_async_fifo_show_ahead_rd_task_logic;