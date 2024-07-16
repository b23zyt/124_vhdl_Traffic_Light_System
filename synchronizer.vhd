--Author: Group 19, Harry Wang, Benjamin Zeng
library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk			: in std_logic;
			reset		: in std_logic;
			din			: in std_logic;
			dout		: out std_logic
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is
	component D_FF port(
			clk	: in std_logic;
			input : in std_logic;
			reset : in std_logic;
			output: out std_logic
		);
	end component;
	Signal sreg				: std_logic_vector(1 downto 0):= "00";

	
BEGIN
--Two DFF to ensure no metastability issues
--Modular DFF to improve reusability
INST1: D_FF port map(clk, din, reset, sreg(0));
INST2: D_FF port map(clk, sreg(0), reset, sreg(1));

dout <= sreg(1);
end;