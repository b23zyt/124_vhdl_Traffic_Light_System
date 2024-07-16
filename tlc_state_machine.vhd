library ieee;
use ieee.std_logic_1164.all;


entity tlc_state_machine is port (
	clk_input		:in std_logic;
	blink_sig		:in std_logic;
	reset				:in std_logic;
	ns_req, ew_req	:in std_logic;
	traffic_light_ns	: out std_logic_vector(6 downto 0);
	traffic_light_ew	: out std_logic_vector(6 downto 0);
	crossing_ns			: out std_logic;
	crossing_ew			: out std_logic;
	ns_clear, ew_clear: out std_logic;
	state_display		: out std_logic_vector (3 downto 0)
);
end entity;

architecture tlc of tlc_state_machine is 


 

 
 SIGNAL current_state, next_state, temp_next	:  std_logic_vector(3 downto 0);     	-- signals of type STATE_NAMES
 SIGNAL blink_green_ns, green_ns, amber_ns, red_ns 	: std_logic;
 SIGNAL blink_green_ew, green_ew, amber_ew, red_ew 	: std_logic;
 SIGNAL jump_ns, jump_ew								: std_logic;
 Signal no_jump											: std_logic;
 signal no_jump_vector									: std_logic_vector(3 downto 0);
 BEGIN
 

 -------------------------------------------------------------------------------
 --State Machine:
 -------------------------------------------------------------------------------
 --transition combination logic 
 --Counter
temp_next(0) <= not(current_state(0));
temp_next(1) <= current_state(0) XOR current_state(1);
temp_next(2) <= (current_state(0) AND current_state(1)) XOR current_state(2);
temp_next(3) <= (current_state(0) AND current_state(1) AND current_state(2)) XOR current_state(3);


--ns traffic light
blink_green_ns <= not(current_state(3)) AND not(current_state(2)) AND not(current_state(1));
green_ns <= (not(current_state(3)) AND not(current_state(2)) AND current_state(1)) OR (not(current_state(3)) AND current_state(2) AND not(current_state(1)));
amber_ns <= not(current_state(3)) AND current_state(2) AND current_state(1);
red_ns <= current_state(3);


traffic_light_ns <= amber_ns & "00" & (green_ns OR (blink_green_ns AND blink_sig)) & "00" & red_ns;
crossing_ns <= green_ns;

--ew traffic lights
blink_green_ew <= current_state(3) AND not(current_state(2)) AND not(current_state(1));
green_ew <= (current_state(3) AND not(current_state(2)) AND current_state(1)) OR (current_state(3) AND current_state(2) AND not(current_state(1)));
amber_ew <= current_state(3) AND current_state(2) AND current_state(1);
red_ew <= not(current_state(3));

traffic_light_ew <= amber_ew & "00" & (green_ew OR (blink_green_ew AND blink_sig)) & "00" & red_ew;
crossing_ew <= green_ew;

--jump
jump_ns <= (current_state(3) AND not(current_state(2)) AND not(current_state(1))) AND ns_req;
jump_ew <= (not(current_state(3)) AND not(current_state(2)) AND not(current_state(1))) AND ew_req;
no_jump <= not(jump_ns OR jump_ew);
no_jump_vector <= (no_jump & no_jump & no_jump & no_jump); 
next_state <= (no_jump_vector AND temp_next) OR ((jump_ns & jump_ns & jump_ns & jump_ns) AND ("1110")) OR ((jump_ew & jump_ew & jump_ew & jump_ew) AND ("0110"));
--next_state <= ((jump_ns & jump_ns & jump_ns & jump_ns) AND ("1101")) OR (NOT(jump_ns & jump_ns & jump_ns & jump_ns) AND (temp_next));

--next_state <= ((jump_ew & jump_ew & jump_ew & jump_ew) AND ("0110")) OR (NOT(jump_ew & jump_ew & jump_ew & jump_ew) AND (temp_next));

 state_display <= current_state;
 -- REGISTER_LOGIC PROCESS EXAMPLE
 
Register_Section: PROCESS (clk_input)  -- this process updates with a clock
BEGIN
	IF(rising_edge(clk_input)) THEN
		IF (reset = '1') THEN
			current_state <= "0000";
		ELSIF (reset = '0') THEN
			current_state <= next_State;
			ns_clear <= jump_ns;
			ew_clear <= jump_ew;
		END IF;
	END IF;
END PROCESS;	
 

-- DECODER SECTION PROCESS EXAMPLE (MOORE FORM SHOWN)

end tlc;