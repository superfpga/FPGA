----------------------------------------------------------------------------------
-- Company:  GKHY
-- Engineer: bingyang.wang
--
-- Create Date:    2014-1-7 9:54:54
-- Project Name:   dm_out_top
-- Module Name:    async_fifo_show_ahead_wr_task_logic - Behavioral
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




ENTITY async_fifo_show_ahead_wr_task_logic IS
    GENERIC (
        FIFO_ADDR_WIDTH	: INTEGER := 8;  -----fifo addr width

        PROG_FULL_THR	: INTEGER := 0   -----fifo program full threshold
    );

    PORT (
        -- Main Write Clock AND Reset#
        wrclk		: IN STD_LOGIC;  ----- aSync Clock for Write
        reset_n		: IN STD_LOGIC;  --- Async RESET#

        -- Async FIFO Interface for write
        wrreq		: IN STD_LOGIC;  --// write request
        wrusedw		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);  --
        prog_full	: OUT STD_LOGIC;  --  programmable full flag(Assert when usedw is greater than or equal to PROG_FULL_THR)
        wrfull		: OUT STD_LOGIC;  --  full flag

        -- Sync dual-clock RAM Interface for write
        wren		: OUT STD_LOGIC;  --  write enable
        wraddr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);  --  Write address

        -- write pointer synchronized to read clock domain
        wrptr		: OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  --  Write pointer

        -- read pointer synchronized from read clock domain
        wrq2_rdptr	: IN STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0)  --  Write address to read pointer
    );
END ENTITY async_fifo_show_ahead_wr_task_logic;





ARCHITECTURE arch_async_fifo_show_ahead_wr_task_logic OF async_fifo_show_ahead_wr_task_logic IS





--*************************************
--			Constant
--*************************************
CONSTANT  DATA_WIDTH	: INTEGER := FIFO_ADDR_WIDTH + 1;




--******************************************************************
--				Function: Binary to Gray Conversion
--*****************************************************************/
function func_wr_bin_to_gray_conv (
    binary	: IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)) return STD_LOGIC_VECTOR IS

        variable bin_to_gray_conv	: STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);       ----Binary to Gray Conversion
    BEGIN
        bin_to_gray_conv := '0' & binary(DATA_WIDTH - 1 DOWNTO 1) xor binary;

        return (bin_to_gray_conv);
END function func_wr_bin_to_gray_conv;



--******************************************************************
--				Function: Gray to Binary Conversion
--*****************************************************************/
function func_wr_gray_to_bin_conv (
    gray	: IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)) return STD_LOGIC_VECTOR IS

        variable i                  :  INTEGER;        ----for circulate
        variable gray_to_bin_conv	: STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);      -----Gray to Binary Conversion
    BEGIN
        gray_to_bin_conv(DATA_WIDTH - 1) := gray(DATA_WIDTH - 1);

        i := DATA_WIDTH - 2;

        while (i >= 0) loop
            gray_to_bin_conv(i) := gray_to_bin_conv(i + 1) xor gray(i);
            i := i - 1;
        END loop;

        return (gray_to_bin_conv);
END function func_wr_gray_to_bin_conv;






--*************************************
--			Signal
--*************************************
SIGNAL	wrbin       : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);       -- binary write address

SIGNAL	wrusedw_r0  : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ---Write usedw register
SIGNAL	wrusedw_r1  : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   ---Write usedw register
SIGNAL	wrusedw_r1_r: STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH + 1 DOWNTO 0);   ---Write usedw register
SIGNAL	wrusedw_r   : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);   ---Write usedw register
SIGNAL	wrusedw_sw  : STD_LOGIC;   ---Write usedw switch

SIGNAL  prog_full_r : STD_LOGIC; -----fifo program full register

SIGNAL	rdptr_bin_r : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);  ---read pointer Binary register

SIGNAL  wrfull_r    : STD_LOGIC;  ---Write full register

SIGNAL	wren_r		: STD_LOGIC;  ---Write request register

SIGNAL  wrfull_val  : STD_LOGIC;  ---Write full register

SIGNAL	rdptr_bin   : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0); ---read pointer Binary

SIGNAL	wrusedw_i   : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0); ---Write usedw input

SIGNAL  wrgray      : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);	--- gray write address
SIGNAL  wbinnext    : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH DOWNTO 0);   --- write address next





----------------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------------




--********************* write address, gray style 2 *****************************
wraddr <= wrbin(FIFO_ADDR_WIDTH - 1 DOWNTO 0);

----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrbin <= (OTHERS => '0');

        wrptr <= (OTHERS => '0');
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        wrbin <= wbinnext;		-- write pointer(binary)

        wrptr <= wrgray;		-- write pointer(gray)
    END IF;
END PROCESS;


wbinnext <= wrbin + wren_r;




--************************ generate write full *******************************
wrfull_val <= '1' WHEN (wrgray = ((NOT wrq2_rdptr(FIFO_ADDR_WIDTH DOWNTO FIFO_ADDR_WIDTH - 1)) & wrq2_rdptr(FIFO_ADDR_WIDTH - 2 DOWNTO 0))) ELSE
              '0';

-- binary convert to gray
--assign wrgray = {1'b0, wbinnext[FIFO_ADDR_WIDTH:1]} ^ wbinnext;
wrgray <= func_wr_bin_to_gray_conv(wbinnext);


-- generate write full flag
wrfull <= wrfull_r;
----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrfull_r <= '0';
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        wrfull_r <= wrfull_val;
    END IF;
END PROCESS;



--************************ generate wrusedw *********************************
wrusedw <= wrusedw_r;

-- gray convert to binary
rdptr_bin <= func_wr_gray_to_bin_conv(wrq2_rdptr);

----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        rdptr_bin_r <= (OTHERS => '0');
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        rdptr_bin_r <= rdptr_bin;
    END IF;
END PROCESS;


----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrusedw_r0 <= (OTHERS => '0');
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        wrusedw_r0 <= wrbin - rdptr_bin_r;
    END IF;
END PROCESS;
----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrusedw_r1_r <= (OTHERS => '0');
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        --wrusedw_r1 <= 2**(FIFO_ADDR_WIDTH+1) - rdptr_bin_r + wrbin;
        wrusedw_r1_r <= ('1' & wrbin) - ('0' & rdptr_bin_r);
    END IF;
END PROCESS;

wrusedw_r1 <= wrusedw_r1_r(FIFO_ADDR_WIDTH DOWNTO 0);
----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrusedw_sw <= '0';
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        IF (wrbin < rdptr_bin_r) THEN
            wrusedw_sw <= '1';
        ELSE
            wrusedw_sw <= '0';
        END IF;
    END IF;
END PROCESS;



wrusedw_i <= wrusedw_r0 WHEN (wrusedw_sw = '0') ELSE
             wrusedw_r1;

----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        wrusedw_r <= (OTHERS => '0');
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        wrusedw_r <= wrusedw_i(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
    END IF;
END PROCESS;




--************************ generate prog full *********************************
prog_full <= prog_full_r;
----------------------------------------------------------------------------------------
PROCESS(wrclk, reset_n)
BEGIN
    IF (reset_n = '0') THEN
        prog_full_r <= '0';
    ELSIF (wrclk'EVENT AND wrclk = '1') THEN
        IF (wrusedw_i >= PROG_FULL_THR) THEN
            prog_full_r <= '1';
        ELSE
            prog_full_r <= '0';
        END IF;
    END IF;
END PROCESS;



-- write enable for synchronous dual-clock ram
wren_r <= wrreq AND (NOT wrfull_r);

wren <= wren_r;



END ARCHITECTURE arch_async_fifo_show_ahead_wr_task_logic;