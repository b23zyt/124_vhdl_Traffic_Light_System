--Author: Group 19, Harry Wang, Benjamin Zeng
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	    : in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic;							-- seg7 digi selectors
	
	sm_clken_sim		:OUT std_logic;
	blink_sig_sim		:OUT std_logic;
	NS_a, NS_g, NS_d	:OUT std_logic;
	EW_a, EW_g, EW_d	:OUT std_logic
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
			 clk        	: in  	std_logic := '0';
			 DIN2 			: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 			: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0);
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;

   component clock_generator port (
			sim_mode			: in boolean;
			reset				: in std_logic;
            clkin      		    : in  std_logic;
			sm_clken			: out	std_logic;
			blink		  		: out std_logic
  );
   end component;

    component pb_filters port (
			clkin				: in std_logic;
			rst_n				: in std_logic;
			rst_n_filtered	    : out std_logic;
			pb_n				: in  std_logic_vector (3 downto 0);
			pb_n_filtered	    : out	std_logic_vector(3 downto 0)							 
 );
   end component;

	component pb_inverters port (
			rst_n				: in  std_logic;
			rst				    : out	std_logic;							 
			pb_n_filtered	    : in  std_logic_vector (3 downto 0);
			pb					: out	std_logic_vector(3 downto 0)							 
  );
   end component;
	
	component synchronizer port(
			clk					: in std_logic;
			reset					: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
   end component; 
	
  component holding_register port (
			clk					: in std_logic;
			reset					: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout					: out std_logic
  );
  end component;

component tlc_state_machine port (
	clk_input			:in std_logic;
	blink_sig			:in std_logic;
	reset					:in std_logic;
	ns_req, ew_req		:in std_logic;			--NS and EW pedestrian crossing requests	
	
	traffic_light_ns	: out std_logic_vector(6 downto 0);
	traffic_light_ew	: out std_logic_vector(6 downto 0);
	crossing_ns			: out std_logic;
	crossing_ew			: out std_logic;
	ns_clear, ew_clear: out std_logic;
	state_display		: out std_logic_vector (3 downto 0);
	
	--simulation outputs
	sm_clken_sim		:OUT std_logic;
	blink_sign_sim		:OUT std_logic;
	NS_a, NS_g, NS_d	:OUT std_logic;
	EW_a, EW_g, EW_d	:OUT std_logic
);
end component;

component State_Machine_TCL Port
(
	clk_input, blink_sig, reset, ns_req, ew_req		: IN std_logic;
	traffic_light_ns, traffic_light_ew 					: OUT std_logic_vector(6 downto 0);
	crossing_ns													: OUT std_logic;
	crossing_ew													: OUT std_logic;
	ns_clear														: OUT std_logic;
	ew_clear														: OUT std_logic;
	state_display												: OUT std_logic_vector(3 downto 0)
 );
END component;  
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode										: boolean := TRUE;  -- set to FALSE for LogicalStep board downloads		-- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst			: std_logic;
	SIGNAL sm_clken, blink_sig							: std_logic; 
	SIGNAL pb_n_filtered, pb							: std_logic_vector(3 downto 0); 
	SIGNAL HLD0_IN, HLD1_IN								: std_logic;	
	SIGNAL traffic_ns, traffic_ew									: std_logic_vector(6 downto 0);
	SIGNAL ns_req, ew_req								: std_logic;
	SIGNAL ns_clr, ew_clr								: std_logic;
	signal blink											: std_logic;
	
BEGIN
----------------------------------------------------------------------------------------------------
INST0: pb_filters		port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered);
INST1: pb_inverters		port map (rst_n_filtered, rst, pb_n_filtered, pb);
INST2: synchronizer     port map (clkin_50,'0', rst, synch_rst);	-- the synchronizer is also reset by synch_rst.

INST3: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink);

--Holding register for pedestrian crossing input
INST4: holding_register port map (clkin_50, synch_rst, ew_clr, HLD1_IN, ew_req);
INST5: holding_register port map (clkin_50, synch_rst, ns_clr, HLD0_IN, ns_req);

--NS and EW pedestrian crossing buttons
INST6: synchronizer     port map (clkin_50, synch_rst, pb(0), HLD0_IN);
INST7: synchronizer     port map (clkin_50, synch_rst, pb(1), HLD1_IN);

INST8: State_Machine_TCL     port map (sm_clken, blink, synch_rst, ns_req, ew_req, traffic_ns, traffic_ew, leds(0), leds(2), ns_clr, ew_clr, leds(7 downto 4));		
	
INST9: segment7_mux port map (clkin_50, traffic_ns, traffic_ew, seg7_data, seg7_char2, seg7_char1);


leds(1) <= ns_req;
leds(3) <= ew_req;

--simulation outputs
sm_clken_sim <= sm_clken;
blink_sig_sim <= blink;

NS_a <= traffic_ns(0);
NS_g <= traffic_ns(6);
NS_d <= traffic_ns(3);

EW_a <= traffic_ew(0);
EW_g <= traffic_ew(6);
EW_d <= traffic_ew(3);

END SimpleCircuit;
