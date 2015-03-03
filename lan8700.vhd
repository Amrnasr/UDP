
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity lan8700 is

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


	RXER : in std_logic;
--	
	RX_DV : in std_logic;
--	
	RXCLK: in std_logic;
--	
--	CRSDV: inout std_logic;
--	
--	CRS: inout std_logic;
--
   MDIO : inout std_logic;

   MDC : out std_logic	


  );



end lan8700;

architecture Behavioral of lan8700 is

-------------------------------------------------------------------
------this is a module for interfacing with the lan chip 8700 -----
-----for physical layer of ethernet -------------------------------
-------------------------------------------------------------------



---------------------------------------------------------------------
---RMII ( Reduced Mode Independent Interface)------------------------
---------------------------------------------------------------------

------------------------------------------------------------------------
---The RMII Mode include 6 signals--------------------------------------

------transmit data -------TXD[1:0]---
-------transmit strobe TX_EN----------
--------receive data RX[1:0]----------
--------	receive error RX_ER----------
--------carrier sense CRS_DV------------
------Reference clock CLKIN/XTAL--------
------

----the lan8700 supports the two modes -----------------------
----MII Mode (Mode Independent Interface ) and RMII mode -----
----through COL/RMII/CRS_DV pin-------------------------------
-----


type MDIORead is (idle, preamble,startofframe,opcode,phyaddress,RegisterAddress,Turnaround,Data);
signal state1 : MDIORead;

type machine2 is (idle, registerzeroreset, registerzeroset,register31set);
signal state2: machine2;

signal count: integer range 0 to 100;
signal startframe: std_logic_vector(1 downto 0):="10";
signal physicaladdress: std_logic_vector(4 downto 0) :="00000";
signal registerzero: std_logic_vector(4 downto 0) :="00000";
signal registerone: std_logic_vector(4 downto 0) := "00001";
signal registertwo : std_logic_vector(4 downto 0) :="00010";
signal registerthree: std_logic_vector(4 downto 0) := "00011";
signal registerfour : std_logic_vector(4 downto 0) :="00100";
signal registerfive: std_logic_vector(4 downto 0) :="00101";
signal registersix: std_logic_vector(4 downto 0) :="00110";
signal registerseven: std_logic_vector(4 downto 0) :="00111";
signal registereight: std_logic_vector(4 downto 0) :="01000";
signal registernine : std_logic_vector(4 downto 0) :="01001";
signal registerten : std_logic_vector(4 downto 0) :="01010";
signal registereleven : std_logic_vector(4 downto 0) :="01011";
signal registertwelve : std_logic_vector(4 downto 0) :="01100";
signal registerthirteen : std_logic_vector(4 downto 0):="01101";
signal registerfourteen : std_logic_vector(4 downto 0) :="01110";
signal registerfifteen : std_logic_vector(4 downto 0) :="01111";
signal registersixteen : std_logic_vector(4 downto 0) :="10000";
signal registerseventeen : std_logic_vector(4 downto 0) :="10001";
signal registereighteen : std_logic_vector(4 downto 0):="10010";
signal registernineteen: std_logic_vector(4 downto 0):="10011";
signal registertwenty : std_logic_vector(4 downto 0) :="10100";
signal registertwentyone: std_logic_vector(4 downto 0):="10101";
signal registertwentytwo : std_logic_vector(4 downto 0) :="10110";
signal registertwentythree: std_logic_vector(4 downto 0) :="10111";
signal registertwentyfour : std_logic_vector(4 downto 0) :="11000";
signal registertwentyfive : std_logic_vector(4 downto 0) := "11001";
signal registertwentysix : std_logic_vector(4 downto 0) :="11010";
signal registertwentyseven : std_logic_vector(4 downto 0) := "11011";
signal registertwentyeight : std_logic_vector( 4 downto 0) :="11100";
signal registertwentynine: std_logic_vector(4 downto 0) :="11101";
signal registerthirty : std_logic_vector(4 downto 0) :="11110";
signal registerthirtyone: std_logic_vector(4 downto 0) :="11111";
signal registercommand : std_logic_vector(4 downto 0) :="00000";

signal value: std_logic_vector(15 downto 0);
signal value1,value2, value3, value4:  std_logic_vector(15 downto 0);
signal count2 : integer range 0 to 1000;

signal rw: std_logic;
signal receivebuffer: std_logic_vector(3 downto 0);

begin

-------------------------------------------------------------------
-----Here is the process for generating MDC and MDIO signals------- 
-----for Read and Write Cycles-------------------------------------
-------------------------------------------------------------------

--RXD0<='0'; ---Mode 0
--RXD1<='0';  ---Mode 1
--RXD2<='1';  ---Mode 2
--
--RXD3<='0'; ---for interrupts

process(RXCLK)
begin


if RXCLK 'event and RXCLK='1' then
  
     receivebuffer<=RXD3&RXD2&RXD1&RXD0;
	  
end if;





end process;



process(rst,TXCLK)
begin

if rst='1' then

   TXD<="0000";
	TXEN<='0';
	TXER<='0';



elsif TXCLK'event and TXCLK='1' then
       ---you can transmit here ------
	  -------------------------------
        if datavalid='1' then
		     TXD<=datain;
--			  TXD<="1101";
			  TXEN<='1';
			else
			   TXD<=(others=>'0');
            TXEN<='0';              
         end if;				
end if; 

end process;





process(clk,rst)
begin
 
 if rst='1' then 
     registercommand<="00000";
     value<=(others=>'0');
	  
	  --rw<='0'; -----Read Cycle-----
	  rw<='1'; -----Write cycle----
	
     value1<="1000000000000000"; ---this for programming register 0------------------------------------------------
	  value2<="0011000000000000"; ----this for programming register 0 to set the speed and program autonegotiation--
	  value3<="0000000001000000"; ----this for setting register 31 to disable scrambling ---------------------------
	  
	  
 elsif clk'event and clk='1' then
    
--	  registercommand<="00000";
	  
--	  value1<="1000000000000000"; ---this for programming register 0------------------------------------------------
--	  value2<="0011000000000000"; ----this for programming register 0 to set the speed and program autonegotiation--
--	  value3<="0000000001000000"; ----this for setting register 31 to disable scrambling ---------------------------
--	  

 ----------------------------------------------------------------------------------------------------------
 ---We are supposed to put here a state machine to move between states programming lan8700 chip registers--
 ----------------------------------------------------------------------------------------------------------
    
	  
	    
	   
	 

	   if count2<100 then
		   count2<=count2+1;
			registercommand<="00000";
			value<=value1;
		elsif count2>=100 and count2<200 then
          registercommand<="00000";
			 value<=value2;
			 count2<=count2+1;
         
      
		elsif count2>=200 and count2<300 then
		      registercommand<=registerthirtyone;
            value<=value3;
            count2<=count2+1;
       
      else 
            null;		
		
		end if;			
	        
	 --------------------------------------
	 ---do nothing now---------------------
	 --------------------------------------
 
 end if;
 
end process;



MDC<=clk;

process(rst,clk,registercommand,value,rw)
begin

if rst='1' then 
  
  state1<=idle;
  MDIO<='0';
  count<=0;

elsif clk'event and clk='1' then

       case (state1) is 
		 
		 
		     when idle=>
			        state1<=preamble;
						
			  when preamble=>
                
					 if count<32 then  
					   MDIO<='1';
					   count<=count+1;
                	state1<=preamble;
                else
					    MDIO<='1';
                   count<=0;
                   state1<=startofframe;
                 end if;						 
					  
			  when startofframe=>
                  
						if count<1 then 
						   MDIO<='0';
						   state1<=startofframe;
							count<=count+1;
						else
						   MDIO<='1';
							state1<=opcode;
							count<=0;
						
						end if;
                    
             
				 when opcode =>
				   -----------------------------
				   ---for the Read Cycle--------
					----We send '1' then '0' ----
					-----------------------------
					-----------------------------
				      if count<1 then 
						   MDIO<='0';
						   state1<=opcode;
							count<=count+1;
						else
						   MDIO<='1';
							state1<=phyaddress;
							count<=0;
						
						end if;
				 
				 
				 when phyaddress=>
                    
					if count<4 then  
					   MDIO<=physicaladdress(count);
					   count<=count+1;
                	state1<=phyaddress;
                else
					    MDIO<=physicaladdress(count);
                   count<=0;
                   state1<=RegisterAddress;
                 end if;			 

              when RegisterAddress=>

                  case(Registercommand) is
						   -------------------------------------------------------
                     ---in this case we are dealing with Register 0---------
							  when "00000"=> null;
                             if count<4 then  
										MDIO<=registerzero(count);
										count<=count+1;
										state1<=RegisterAddress;
									 else
										 MDIO<=registerzero(count);
										 count<=0;
										 state1<=Turnaround;
									  end if;			 
  
                         when "00001" =>
										 if count<4 then  
											MDIO<=registerone(count);
											count<=count+1;
											state1<=RegisterAddress;
										 else
											 MDIO<=registerone(count);
											 count<=0;
											 state1<=Turnaround;
										 end if;									 

                         when "11111" =>
                               if count<4 then  
											MDIO<=registerthirtyone(count);
											count<=count+1;
											state1<=RegisterAddress;
										 else
											 MDIO<=registerthirtyone(count);
											 count<=0;
											 state1<=Turnaround;
										 end if;			
                                  								 

      						when others=>
							              null;
                  
						
						
						
						end case;						  

   		 when Turnaround=> 
                         state1<=Data;		 


           when Data =>
			             ------------------------------------------------------------
			             ---here to reset register 0 for Software reset--------------
							 ------------------------------------------------------------
                      if count<15 then  
											MDIO<=value(count);
											count<=count+1;
											state1<=Data;
							 else
											 MDIO<=value(count);
											 count<=0;
											 state1<=idle;
							 end if;	
							 --------------------------------------------------------------
							 --------------------------------------------------------------
							 --------------------------------------------------------------
                        
					  
           when others=>
                   null;

       end case;						 

   
end if;


end process;


end Behavioral;

