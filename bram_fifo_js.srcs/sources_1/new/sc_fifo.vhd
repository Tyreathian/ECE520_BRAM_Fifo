library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sc_fifo is
Generic (
    width : integer := 16;
    depth : integer := 32;
    read_latency : integer range 1 to 8 := 2
);
Port (
    clk : in std_logic;
    srst : in std_logic;
    data_in : in std_logic_vector(15 downto 0);
    write_enable : in std_logic;
    read_enable : in  std_logic;

    data_count : out integer range 0 to depth := 0;
    valid : out std_logic := '0';
    data_out : out std_logic_vector(15 downto 0) := (others => '0');
    almost_empty_threshold : out std_logic := '1'; 
    almost_full_threshold : out std_logic := '0'; 
    full : out std_logic := '0'; 
    empty : out std_logic := '1'  
);
end sc_fifo;

architecture Behavioral of sc_fifo is

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) 
  );
END COMPONENT;

-- signals for the ports and bram
signal write_reg : unsigned(4 downto 0) := (others => '0');
signal read_reg : unsigned(4 downto 0) := (others => '0');
signal counter : integer range 0 to depth := 0;

signal bram_addra : std_logic_vector(4 downto 0);
signal bram_en : std_logic;
signal bram_we : std_logic_vector(0 downto 0);
signal bram_dout : std_logic_vector(width-1 downto 0);

signal valid_ram : std_logic := '0';

type pipeline_data_type is array (0 to 8) of std_logic_vector(width-1 downto 0);
type pipeline_valid_type is array (0 to 8) of std_logic;
signal pipe_data : pipeline_data_type := (others => (others => '0'));
signal pipe_valid : pipeline_valid_type := (others => '0');

signal is_full  : std_logic := '0';
signal is_empty : std_logic := '1';

signal write_valid : std_logic;
signal read_valid  : std_logic;

begin

is_full     <= '1' when counter = depth else '0';
is_empty    <= '1' when counter = 0 else '0';

write_valid <= '1' when (write_enable = '1' and is_full = '0') else '0';
read_valid  <= '1' when (read_enable = '1' and is_empty = '0' and write_valid = '0') else '0';


bram_addra <= std_logic_vector(write_reg) when (write_valid = '1') else std_logic_vector(read_reg);
bram_en    <= '1' when (write_valid = '1' or read_valid = '1') else '0';
bram_we(0) <= write_valid;

bram_instance : blk_mem_gen_0
  PORT MAP (
    clka => clk,
    ena => bram_en,
    wea => bram_we,
    addra => bram_addra,
    dina => data_in,
    douta => bram_dout
  );

process(clk)
begin
    if rising_edge(clk) then
        if srst = '1' then
            write_reg  <= (others => '0');
            read_reg   <= (others => '0');
            counter    <= 0;
            valid_ram  <= '0';
        else
            valid_ram <= read_valid;
    
        if write_valid = '1' then
           write_reg <= write_reg + 1;
           counter   <= counter + 1;
        elsif read_valid = '1' then
           read_reg  <= read_reg + 1;
           counter   <= counter - 1;
        end if;
        end if;
    end if;
end process;

process(clk)
begin
    if rising_edge(clk) then
        if srst = '1' then
            valid_ram <= '0';
            pipe_valid <= (others => '0');
            pipe_data <= (others => (others => '0'));

        else
            valid_ram <= read_valid;
            pipe_valid(0) <= valid_ram;
            pipe_data(0) <= bram_dout;

            for k in 1 to 8 loop
                pipe_valid(k) <= pipe_valid(k-1);
                pipe_data(k) <= pipe_data(k-1);
            end loop;
        end if;
    end if;
end process;

data_out   <= bram_dout when (read_latency = 2) else pipe_data(read_latency - 1);
valid      <= valid_ram when (read_latency = 2) else pipe_valid(read_latency - 1);
data_count <= counter;

empty <= is_empty;
full  <= is_full;

almost_empty_threshold <= '1' when counter <= 1 else '0';
almost_full_threshold  <= '1' when counter >= depth - 1 else '0';

end Behavioral;
