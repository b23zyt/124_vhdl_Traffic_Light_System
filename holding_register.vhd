--Author: Group 19, Harry Wang, Benjamin Zeng
library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (

			clk					: in std_logic;
			reset				: in std_logic;
			register_clr		: in std_logic;
			din					: in std_logic;
			dout				: out std_logic
  );
 end holding_register;
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;
	signal dff_out			: std_logic;

BEGIN

--First DFF output goes into second DFF, second DFF output is holding register output

sreg <= (NOT(register_clr OR reset) AND (dff_out or din));
dff: process(clk, sreg)
begin
	if(rising_edge(clk)) then
		dff_out <= sreg;
	else 
		dff_out <= dff_out;
	end if;

end process;
dout <= dff_out;

end;