LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;
use work.pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

ENTITY async_fifo_tb IS
  GENERIC (
    FIFO_DATA_WIDTH	: INTEGER := 32;  -----fifo data width
    FIFO_ADDR_WIDTH	: INTEGER := 8;   -----fifo addr width

    PROG_FULL_THR	: INTEGER := 32;   -----fifo program full threshold
    PROG_EMPTY_THR	: INTEGER := 8    -----fifo program empty threshold
    );
END async_fifo_tb;

ARCHITECTURE behavior OF async_fifo_tb IS

  -- Component Declaration for the Unit Under Test (UUT)
  component async_fifo_show_ahead is
    generic (
      FIFO_DATA_WIDTH : INTEGER;
      FIFO_ADDR_WIDTH : INTEGER;
      PROG_FULL_THR   : INTEGER;
      PROG_EMPTY_THR  : INTEGER);
    port (
      wrclk      : IN  STD_LOGIC;
      rdclk      : IN  STD_LOGIC;
      reset_n    : IN  STD_LOGIC;
      wrreq      : IN  STD_LOGIC;
      data       : IN  STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0);
      rdreq      : IN  STD_LOGIC;
      q          : OUT STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0);
      wrusedw    : OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
      rdusedw    : OUT STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
      prog_full  : OUT STD_LOGIC;
      prog_empty : OUT STD_LOGIC;
      wrfull     : OUT STD_LOGIC;
      rdempty    : OUT STD_LOGIC);
  end component async_fifo_show_ahead;

  signal wrclk      : STD_LOGIC := '0';
  signal rdclk      : STD_LOGIC := '0';
  signal reset_n    : STD_LOGIC := '1';
  signal wrreq      : STD_LOGIC := '0';
  signal data_internal       : STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0) := (others => '0');
  signal data       : STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0) := (others => '0');
  signal rdreq      : STD_LOGIC := '0';
  signal q          : STD_LOGIC_VECTOR(FIFO_DATA_WIDTH - 1 DOWNTO 0);
  signal wrusedw    : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
  signal rdusedw    : STD_LOGIC_VECTOR(FIFO_ADDR_WIDTH - 1 DOWNTO 0);
  signal prog_full  : STD_LOGIC;
  signal prog_empty : STD_LOGIC;
  signal wrfull     : STD_LOGIC;
  signal rdempty    : STD_LOGIC;

  signal sys_rst_n : std_logic := '1';
  signal sys_clk : std_logic := '0';
  signal sys_rd_clk : std_logic := '0';

  --Clock period definitions
  constant sys_clk_period : time := 40 ns;
  constant sys_rd_clk_period : time := 20 ns;

BEGIN

  wrclk <= sys_clk;
  rdclk <= sys_rd_clk;
  reset_n <= sys_rst_n;
  rdreq <= '1' when prog_empty = '0' else '0';

  process(sys_clk,sys_rst_n)
  begin
    if sys_rst_n = '0' then
      wrreq <= '0';
    elsif rising_edge(sys_clk) then
      if prog_full = '0' then
        wrreq <= '1';
      else
        wrreq <= '0';
      end if;
    end if;

  end process;

  process(sys_clk,sys_rst_n)
  begin
    if sys_rst_n = '0' then
      data_internal <= (others => '0');
    elsif rising_edge(sys_clk) then
      if wrreq = '1' then
        data_internal <= data_internal + 1;
      end if;
    end if;

  end process;

  data <= data_internal;


  async_fifo_show_ahead_1: async_fifo_show_ahead
    generic map (
      FIFO_DATA_WIDTH => FIFO_DATA_WIDTH,
      FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH,
      PROG_FULL_THR   => PROG_FULL_THR,
      PROG_EMPTY_THR  => PROG_EMPTY_THR)
    port map (
      wrclk      => wrclk,
      rdclk      => rdclk,
      reset_n    => reset_n,
      wrreq      => wrreq,
      data       => data,
      rdreq      => rdreq,
      q          => q,
      wrusedw    => wrusedw,
      rdusedw    => rdusedw,
      prog_full  => prog_full,
      prog_empty => prog_empty,
      wrfull     => wrfull,
      rdempty    => rdempty);

  -- Clock process definitions
  sys_clk_process :process
  begin
    sys_clk <= '0';
    wait for sys_clk_period/2;
    sys_clk <= '1';
    wait for sys_clk_period/2;
  end process;

  sys_rd_clk_process :process
  begin
    sys_rd_clk <= '0';
    wait for sys_rd_clk_period/2;
    sys_rd_clk <= '1';
    wait for sys_rd_clk_period/2;
  end process;

  -- Stimulus process
  stim_proc: process
  begin
    -- hold reset state for 100 ns.
    sys_rst_n <= '0';
    wait for 95 ns;
    sys_rst_n <= '1';



    wait;
  end process;

  process
  begin
    fsdbDumpfile("debussy.fsdb");
    fsdbDumpvars(0, "async_fifo_tb");
    wait;
  end process;

END;
