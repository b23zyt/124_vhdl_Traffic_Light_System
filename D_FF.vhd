library ieee;
use ieee.std_logic_1164.all;

entity D_FF is 
	port(
		clk	: in std_logic;
		input : in std_logic;
		reset : in std_logic;
		output: out std_logic
	);
end D_FF;

architecture logic of D_FF is
begin
	flip_flop: process(clk)
	begin
		if(rising_edge(clk)) then
			output <= input AND NOT(reset);
		end if;
	end process;
end logic;