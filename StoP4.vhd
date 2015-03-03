
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity StoP4 is

port(
  
  clk: in std_logic;
  rst: in std_logic;
  datain: in std_logic;
  DataReady: out std_logic;
  parallel: out std_logic_vector(3 downto 0)
  
  );



end StoP4;
architecture Behavioral of StoP4 is

signal temp : std_logic_vector(3 downto 0):="0000";
signal count : std_logic_vector(1 downto 0):="00";

begin

process(clk,rst)
begin


  if rst='1' then 
     
	  temp<=(others=>'0');
     count<=(others=>'0');
	  DataReady<='0';
	  
  elsif clk'event and clk='1' then
     if count<3 then 
	     temp(3 downto 0) <=temp(2 downto 0) & datain;
	  
	  else 
	       DataReady<='1';
			 temp(3 downto 0) <=temp(2 downto 0) & datain;
           			  
     end if;	  
	
  end if;	



end process;


parallel<=temp;

end Behavioral;

