--Author: Group 19, Harry Wang, Benjamin Zeng
library ieee;
use ieee.std_logic_1164.all;
A
entity D_FF is 
	port(
		clk	: in std_logic;
		input : in std_logic;
		reset : in std_logic;
		output: out std_logic
	);
end D_FF;

architecture logic of D_FF is
--flip flop sets output to input value on rising edge
--flip flop resets output value to 0 when reset is high
begin
	flip_flop: process(clk)
	begin
		if(rising_edge(clk)) then
			output <= input AND NOT(reset);
		end if;
	end process;
end logic;