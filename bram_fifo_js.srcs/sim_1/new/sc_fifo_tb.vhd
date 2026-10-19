library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sc_fifo_tb is
--  Port ( );
end sc_fifo_tb;

architecture Behavioral of sc_fifo_tb is

component sc_fifo is
Generic (
width : integer := 16;
depth : integer := 32;
read_latency : integer := 2
);

port (
clk : in std_logic;
srst : in std_logic;
data_in : in std_logic_vector(15 downto 0) := (others => '0');
write_enable : in std_logic;
read_enable : in std_logic;

data_count : out integer range 0 to depth;
valid : out std_logic;
data_out : out std_logic_vector(15 downto 0);
almost_full_threshold : out std_logic;
almost_empty_threshold : out std_logic;
full : out std_logic;
empty : out std_logic
);
end component;

signal clk : std_logic := '0';
signal srst : std_logic := '1';
signal data_in : std_logic_vector(15 downto 0) := (others => '0');
signal write_enable : std_logic := '0';
signal read_enable : std_logic := '0';
signal data_count : integer := 0;
signal valid : std_logic := '0';
signal data_out : std_logic_vector(15 downto 0) := (others => '0');
signal almost_full : std_logic := '0';
signal almost_empty: std_logic := '1';
signal full : std_logic := '0';
signal empty : std_logic := '1';

-- 50 Mhz clock
constant clk_period : time := 20ns;

begin

UUT: sc_fifo
port map (
clk => clk,
srst => srst,
write_enable => write_enable,
read_enable => read_enable,
data_count => data_count,
valid => valid,
data_in => data_in,
data_out => data_out,
almost_full_threshold => almost_full,
almost_empty_threshold => almost_empty,
full => full,
empty => empty
);

clk_process : process
begin
clk <= '0';
wait for clk_period/2;
clk <= '1';
wait for clk_period/2;
end process;

stim_process : process
begin
-- start with reset, Test Case 1: output should be 0
srst <= '1';
write_enable <= '0';
read_enable <= '0';
wait for clk_period;

srst <= '0';
wait for clk_period;
-- Write to every memory location
write_enable <= '1';

for i in 0 to 7 loop
wait for clk_period;
data_in <= x"FFFF";
wait for clk_period;
data_in <= x"0000";
wait for clk_period;
data_in <= x"AAAA";
wait for clk_period;
data_in <= x"5555";
end loop;

data_in <= x"0000";
-- turn off write
write_enable <= '0';
wait until rising_edge(clk);

-- turn on reading
read_enable <= '1';

for i in 0 to 7 loop
assert (data_out = x"FFFF") report "Read Error: Expected 0xFFFF" severity error;
wait until rising_edge(clk);
assert (data_out = x"0000") report "Read Error: Expected 0x0000" severity error;
wait until rising_edge(clk);
assert (data_out = x"AAAA") report "Read Error: Expected 0xAAAA" severity error;
wait until rising_edge(clk);
assert (data_out = x"5555") report "Read Error: Expected 0x5555" severity error;
wait until rising_edge(clk);
end loop;

read_enable <= '0';
wait until rising_edge(clk);

wait;
end process;
end Behavioral;
