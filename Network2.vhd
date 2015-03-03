
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Network2 is

port(


clk: in std_logic;
button: in std_logic;
TXD: out std_logic_vector(3 downto 0);
TXER: out std_logic;
	
	TXEN: out std_logic;
	
	TXCLK : in std_logic;

nRST : in std_logic;


	
	RXD0: in std_logic;
--	Mode 0
   RXD1: in std_logic;
   --Mode 1
	
	RXD2: in std_logic;
  ---Mode 2
  
   RXD3: in std_logic;
   ----INTEL
	
	
	RXER : in std_logic;
--	
	RXDV : in std_logic;
--	
	RXCLK: in std_logic;
	
	
	MDC: out std_logic;
	MDIO: inout std_logic;
	
	
rst: in std_logic);


end Network2;

architecture Behavioral of Network2 is

component IPPacket is
port(
 clk: in std_logic;
 rst : in std_logic;
 Button : in std_logic;
 packet: out std_logic



);


end component;


component StoPa4a is

port(
  
  clk: in std_logic;
  rst: in std_logic;
  datain: in std_logic;
  DataReady: out std_logic;
  parallel: out std_logic_vector(3 downto 0)
  
  );



end component;

component lan8700 is

port(
   clk: in std_logic;
	rst: in std_logic;
	
	TXD: out std_logic_vector(3 downto 0);
	
	datain: in std_logic_vector(3 downto 0);
	
	datavalid: in std_logic;
	
	
	TXER: out std_logic;
	
	TXEN: out std_logic;
	
	TXCLK : in std_logic;
 
  nRST: in std_logic;
	
	RXD0: in std_logic;
--	Mode 0
   RXD1: in std_logic;
   --Mode 1
	
	RXD2: in std_logic;
  ---Mode 2
  
   RXD3: in std_logic;
   ----INTEL

 
--	RXD: in std_logic_vector(3 downto 0);
--	
	RXER : in std_logic;
	
	RX_DV : in std_logic;
	
	RXCLK: in std_logic;
--	
--	CRSDV: inout std_logic;
--	
--	CRS: inout std_logic;

   MDIO : inout std_logic;

   MDC : out std_logic	


  );
end component;


signal count: integer range 0 to 10;
signal clk5MHz:std_logic;
signal packet: std_logic;
signal parallel: std_logic_vector(3 downto 0);
signal DataReady: std_logic;

begin

process(rst,clk)
begin
 
 if rst='1' then
 
    count<=0;
	 clk5MHz<='0';
	 
 elsif clk'event and clk='1' then
      
		if count <10 then
		    clk5MHz<=not clk5MHz;
			 count<=count+1;
		else
          count<=0;
       end if;			 
		   
    
 
 end if;


end process;





u1:IPPacket port map
(
 clk =>clk5MHz,
 rst  =>rst,
 Button => button ,
 packet=> packet


);



u2:  StoPa4a port map
(
 clk=> clk5MHz,
  rst=> rst,
  datain=> packet,
  DataReady => DataReady,
  parallel => parallel


);


u3: lan8700 port map
(
clk=> clk5MHz,
rst => rst,
	
	TXD=> TXD,
	
	datain => parallel,
	
	datavalid=> DataReady,
	
	
	TXER => TXER,
	
	TXEN => TXEN,
	
	TXCLK  => TXCLK,
	
	
	nRST=> nRST,
	
	RXD0=> RXD0,
--	Mode 0
   RXD1=> RXD1,
   --Mode 1
	
	RXD2=> RXD2,
  ---Mode 2
  
   RXD3=> RXD3,
   ----INTEL
	
--	RXD => open,
	
	RXER => RXER,
	
	RX_DV => RXDV,
	
	RXCLK => RXCLK,
--	
--	CRSDV => open,
--	
--	CRS => open,

   MDIO => MDIO,

   MDC  => MDC




);




end Behavioral;

