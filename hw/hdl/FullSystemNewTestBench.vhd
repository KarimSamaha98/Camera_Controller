library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cmos_sensor_output_generator_constants.all;

entity FullSystemTestBench is
end FullSystemTestBench;

architecture sim of FullSystemTestBench is
	constant CLK_PERIOD : time := 20 ns;
	signal sim_finished : boolean := false;
	constant PIX_DEPTH : positive := 12;
	constant MAX_WIDTH : positive := 640;
	constant MAX_HEIGHT : positive := 480;
	constant CBURST : STD_LOGIC_VECTOR(7 downto 0) := X"50";

	--CMOS PORTS
	--inputs
	signal clk : std_logic;
	signal reset : std_logic;

	--AVALON MM SLAVE
	signal addr        :  std_logic_vector(2 downto 0);
    signal read        :  std_logic;
    signal write       :  std_logic;
    signal rddata      :  std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);
    signal wrdata      :  std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);

	--Outputs
	signal frame_valid : std_logic;
    signal line_valid  : std_logic;
    signal data        : std_logic_vector(PIX_DEPTH - 1 downto 0);
    signal MasterOutput : std_logic_vector(31 downto 0);	
    signal word32count: STD_LOGIC_VECTOR (8 DOWNTO 0);
    signal empty: std_logic;

begin 

	--Instantiate DUT
	dut : entity work.FullSystemSimulationTDR5

	port map(clk => clk,
			 reset => reset,
			 address => addr,
			 read => read,
			 write => write,
			 readdata => rddata,
             writedata => wrdata);
	
	--Generate clk signal
	clk_generation: process
	begin
		if not sim_finished then
			clk <= '1';
			wait for CLK_PERIOD / 2;
			clk <= '0';
			wait for CLK_PERIOD / 2;
		else
			wait;
		end if;
	end process clk_generation;

	--Test adder_sequential
	simulation : process
	begin 
		--Configure the CMOS
        --Clear the reset signal
		reset <= '1';
		wait for CLK_PERIOD;
		reset <= '0';
		wait for CLK_PERIOD;
        --Turn off the moule for configuration
		write <= '1';
		addr <= CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST;
		wrdata <= x"00000000";
		wait for 1*CLK_PERIOD;
		write <= '0';
		wait for 1*CLK_PERIOD;
        --Configure the registers
        write <= '1';
	read <= '0';
        addr <= CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST;
		--wrdata <= x"00000280";
		wrdata <= x"00000008";
        wait for 1*CLK_PERIOD;
        write <= '0';
        wait for 1*CLK_PERIOD;
        --Configure the registers
        write <= '1';
        addr <= CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST;
		--wrdata <= x"000001E0";
		wrdata <= x"0000000C";
        wait for 1*CLK_PERIOD;
        write <= '0';
        wait for 1*CLK_PERIOD;
         --Configure the registers
         write <= '1';
         addr <= CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST;
         --wrdata <= x"000001E0";
         wrdata <= x"00000003";
         wait for 1*CLK_PERIOD;
         write <= '0';
         wait for 1*CLK_PERIOD;
         --Configure the registers
         write <= '1';
         addr <= CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST;
         --wrdata <= x"000001E0";
         wrdata <= x"000000FF";
         wait for 1*CLK_PERIOD;
         write <= '0';
         wait for 1*CLK_PERIOD;
        --Turn on the module
        write <= '1';
        addr <= CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST;
        wrdata <= x"00000001";
        wait for 1*CLK_PERIOD;
        write <= '0';
	wait for 1*CLK_PERIOD;
	--write <= '1';
        --addr <= "000";
        --wrdata <= x"00000000";
	--wait for 1*CLK_PERIOD;
        --write <= '0';
	--wait for 1*CLK_PERIOD;
	--write <= '1';
	--addr <= "001";
        --wrdata <= x"00001000";
	--wait for 1*CLK_PERIOD;
	--write <= '0';
	wait for 1*CLK_PERIOD;
	read <= '1';
        addr <= "000";
	wait for 1*CLK_PERIOD;
        read <= '0';
	wait for 1*CLK_PERIOD;
	read <= '1';
	addr <= "001";
	wait for 1*CLK_PERIOD;
	read <= '0';
        wait for 10*CLK_PERIOD;
	read <= '1';
	addr <= "010";
	wait for 1*CLK_PERIOD;
	read <= '0';
	wait for 190*CLK_PERIOD;       
		sim_finished <= true;
		wait;
	end process simulation;
end architecture sim;




