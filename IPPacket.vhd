
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IPPacket is
port(
 clk: in std_logic;
 rst : in std_logic;
 Button : in std_logic;
 packet: out std_logic



);


end IPPacket;

architecture Behavioral of IPPacket is
-------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
signal premable: std_logic_vector(55 downto 0):="01010101010101010101010101010101010101010101010101010101";
--signal --macdest: std_logic_vector(47 downto 0):="100101000100001001111010101110101110011010010000";---------
signal macdest: std_logic_vector(47 downto 0):=x"90E6BA7A4294";

signal macsrc: std_logic_vector(47 downto 0):= "010101010100010000110011001000100001000100000000";---------
signal dtemp1: std_logic_vector(7 downto 0) :="11010101";  ---5D hex value---------------------------------
------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
signal macprotocol : std_logic_vector(15 downto 0):="0000100000000000";
signal versionlength: std_logic_vector(7 downto 0):="01000101";
signal dsec: std_logic_vector(7 downto 0) :="00000000";
---------------------------------------------------------------
---------------------------------------------------------------
---------------------------------------------------------------
signal iplength:std_logic_vector(15 downto 0):="0000000000110000";-----ip length here will be 48-------
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------
signal id: std_logic_vector(15 downto 0):="0000000000000000";
signal fragments: std_logic_vector(15 downto 0):="0000000000000000";
signal timetolive: std_logic_vector(7 downto 0):="10000000";
signal protocol: std_logic_vector(7 downto 0):="00010001";
signal headchecksum: std_logic_vector(15 downto 0):="0000000000000000";
signal srcip: std_logic_vector(31 downto 0):="00001010000010000000001010110110";
signal udpport: std_logic_vector(15 downto 0):="0000001100001001";
signal packetlength: std_logic_vector(15 downto 0):="0000000000110000";
signal checksum: std_logic_vector(15 downto 0):="0000000000000000";
signal payload: std_logic_vector(159 downto 0):=(others=>'1');

--			   
--			packet1->src_ip[0] = 10;
--			packet1->src_ip[1] = 8;
--			packet1->src_ip[2] = 2;
--			packet1->src_ip[3] = 182;
--signal dstip: std_logic_vector(31 downto 0):="00001010000010000000001010110111";
signal dstip: std_logic_vector(31 downto 0):=X"0A0802B7";
--			packet1->dst_ip[0] = 10;
--			packet1->dst_ip[1] = 8;
--			packet1->dst_ip[2] = 2;
--			packet1->dst_ip[3] = 183;
--              
           


signal count : integer range 0 to 100;


type statemachine is (idle,preamble,D1, macdest1,macsrc1,macprotocol1,versionandheaderlength,ds_ec,ip_length,id1,fragments1,timetolive1,protocol1,headchecksum1,srcip1,dstip1,srcport,destport,packetlength1,checksum1,datapayload);

signal present_state: statemachine;
--mac[0] = 0x00;
--   mac[1] = 0x11;
--   mac[2] = 0x22;
--   mac[3] = 0x33;
--   mac[4] = 0x44;
--   mac[5] = 0x55; 

---------------------------------------------------------------------
-----here we set the crc calculated signal---------------------------
---------------------------------------------------------------------
-----
signal CRC32init: std_logic_vector(31 downto 0) :=x"ffffffff";
signal CRC32polyInv: std_logic_vector(31 downto 0) :=x"EDB88320";-----CRC32 polynom (0x04C11DB7) in inverted bits order
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-----these are the buffers used for calculating the crc message-----------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

signal MACDestAddr5: std_logic_vector(7 downto 0);
signal MACDestAddr4: std_logic_vector(7 downto 0);
signal MACDestAddr3: std_logic_vector(7 downto 0);
signal MACDestAddr2: std_logic_vector(7 downto 0);
signal MACDestAddr1: std_logic_vector(7 downto 0);
signal MACDestAddr0: std_logic_vector(7 downto 0);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----MAC Source address -----------------------------------------------------------
-----------------------------------------------------------------------------------

signal MACSourceAddr5: std_logic_vector(7 downto 0);
signal MACSourceAddr4: std_logic_vector(7 downto 0);
signal MACSourceAddr3: std_logic_vector(7 downto 0);
signal MACSourceAddr2: std_logic_vector(7 downto 0);
signal MACSourceAddr1: std_logic_vector(7 downto 0);
signal MACSourceAddr0: std_logic_vector(7 downto 0);

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--.set	Message  =	(EthPacketType >> 8)		; MSB of Ethernet Packet Type
--.set	Message  =	(EthPacketType >> 0)		; LSB

-------------------------------------------------------------------------------------
----EtherPacketType is 0800 16 bit we will read it one byte at a time ---------------
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
signal EtherPacketType8 : std_logic_vector(7 downto 0):="00001000";
signal EtherPacketType0 : std_logic_vector(7 downto 0):="00000000";

--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
signal IPVersionLength: std_logic_vector(7 downto 0) :="01000101";

signal iptypeofservice: std_logic_vector(7 downto 0) :="00000000";
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

signal IPLength8 : std_logic_vector(7 downto 0) :="00000000";
signal IPLength0 : std_logic_vector(7 downto 0) :="00110000";

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

signal IPDatagramID8: std_logic_vector(7 downto 0):="00000000" ;
signal IPDatagramID0: std_logic_vector(7 downto 0):="00110000";

signal IPFlags: std_logic_vector(7 downto 0):="00000000";
signal IPOffset: std_logic_vector(7 downto 0):="00000000";


signal IPTimeToLive: std_logic_vector(7 downto 0):="10000000";
signal IPUsedProtocol: std_logic_vector(7 downto 0):="00010001";

signal IPHeaderChecksum8: std_logic_vector(7 downto 0);
signal IPHeaderChecksum0: std_logic_vector(7 downto 0);
signal IPSourceAddr3	: std_logic_vector(7 downto 0);
--signal 

signal IPSourceAddr2	: std_logic_vector(7 downto 0);
signal IPSourceAddr1	: std_logic_vector(7 downto 0);
signal IPSourceAddr0	: std_logic_vector(7 downto 0);

-----------------------------------------------------------------------
-----------------------------------------------------------------------
------------------------------------------------------------------------
signal IPDestAddr3	: std_logic_vector(7 downto 0);
signal IPDestAddr2	: std_logic_vector(7 downto 0);
signal IPDestAddr1	: std_logic_vector(7 downto 0);
signal IPDestAddr0	: std_logic_vector(7 downto 0);

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------






begin
--
--			packet1->mac_dest[0] = 0x90;
--			packet1->mac_dest[1] = 0xE6;
--			packet1->mac_dest[2] = 0xBA;
--			packet1->mac_dest[3] = 0x7A;
--			packet1->mac_dest[4] = 0x42;
--			packet1->mac_dest[5] = 0x94;
--			


headchecksum<=srcip(31 downto 16)+ srcip(15 downto 0)+dstip(31 downto 16)+dstip(15 downto 0)+headchecksum(15 downto 0)+IPTimeToLive(7 downto 0)&IPUsedProtocol(7 downto 0)+IPFlags(7 downto 0)&IPOffset(7 downto 0)+id(15 downto 0)+iplength(15 downto 0)+iplength(15 downto 0)+versionlength(7 downto 0)&dsec(7 downto 0);
IPHeaderChecksum8<=headchecksum(15 downto 8);
IPHeaderChecksum0<=headchecksum(7 downto 0);

process(clk,rst)
begin


if rst='1' then  
     
	  count<=0;
	  packet<='0';
	  present_state<=idle;
elsif clk'event and clk='1' then
       case present_state is
		 
		 when idle =>
--		           if Button='1' then
--					  
					     present_state<=preamble;
--					  else
--                     present_state<=idle;
--                 end if;							
		  --------------------------------------------------			  
		  ----Here we send ethernet preamble ---------------
		  --------------------------------------------------
		  when preamble => 
--                 packet<='0';
					  
					  if count>=55 then
					         packet<=premable(count);
					  		  present_state<=D1;
							  count<=0;
					  else
					     count<=count+1;
						  packet<=premable(count);
						  present_state<=preamble;
						end if;  
			
			
			when D1=>
			          if count>=7 then
						    packet<=dtemp1(count);
						    present_state<=macdest1;
			             count<=0;
						  else
						     packet<=dtemp1(count);
							  count<=count+1;
							  present_state<=D1;
						  end if;  
		   -----------------------------------------------------------				  
			------ ///// Destination MAC Address : Broad Cast /////----
         -----------------------------------------------------------			
			when macdest1=>
			           
			            if count>=47 then
							     present_state<=macsrc1;
							     packet<=macdest(count);
								  count<=0;
							 else
                         	packet<=macdest(count);						 
			                  count<=count+1;
									 present_state<=macdest1;
							 end if;		 
			
			--------------------------------------------------------------
			----///// Source MAC Address : 00:11:22:44:55-----------------
			---------------------------------------------------------------
			when macsrc1=> 
			              if count>=47 then
							     present_state<=macprotocol1;
							     packet<=macdest(count);
								  count<=0;
							 else
                         	packet<=macsrc(count);						 
			                  count<=count+1;
									 present_state<=macsrc1;
							 end if;		 
			-----------------------------------------------------------------
			------///// Protocol IP ////////////////////////////////---------
			-----------------------------------------------------------------
			when macprotocol1=>
			               if count>=15 then
								    packet<=macprotocol(count);
								    present_state<=versionandheaderlength;
								else
                             packet<=macprotocol(count);
                             count<=count+1;
                              present_state<=macprotocol1;									  
			               end if;
			
			---------------------------------------------------------------------
         ------///// IP Header //////////////////////////////////-------------
			---------------------------------------------------------------------
			------- /// Version and Header Length
             
			
			when versionandheaderlength=>
			
			               if count>=7 then
								    packet<=versionlength(count);
								    present_state<=ds_ec;
								else
                             packet<=versionlength(count);
                             count<=count+1;
                              present_state<=versionandheaderlength;									  
			               end if;
			
			   ---------------------------------------------------
				-----ds_ec ----1 byte------------------------------
				---------------------------------------------------
			when ds_ec=>
                        if count>=7 then
								    packet<=dsec(count);
								    present_state<=ip_length;
								else
                             packet<=dsec(count);
                             count<=count+1;
                              present_state<=ds_ec;									  
			               end if;
         ---------------------------------------------------------------------------             		
			-----ip_length  = 28 + DATALENGTH; /// Total length of the UDP Packet------
          --------------------------------------------------------------------------
           ----Datalength will be 20 bytes -----------------------------------------
           -------------------------------------------------------------------------------------
           -------------------------------------------------------------------------------------			  \\\
			  when ip_length=>
			  
			                if count>=15 then
								    packet<=iplength(count);
									 present_state<=id1;
								    count<=0;
                         else 
                             packet<=iplength(count);								 
			                    count<=count+1;
									   present_state<=ip_length;			  
			                end if;
			  
			  when id1=>
			              if count>=15 then 
							       packet<=id(count);
									 present_state<=fragments1;
								    count<=0;
                         else 
                             packet<=id(count);								 
			                    count<=count+1;
									   present_state<=id1;  
			                end if;
			  
			
			  when fragments1=>
			               if count>=15 then 
							       packet<=fragments(count);
									 present_state<=timetolive1;
								    count<=0;
                         else 
                             packet<=fragments(count);								 
			                    count<=count+1;
									   present_state<=fragments1;  
			                end if;
								 
			  	when timetolive1=>				 
			             if count>=7 then
							       packet<=timetolive(count);
									 present_state<=protocol1;
								    count<=0;
                       else 
                             packet<=timetolive(count);								 
			                    count<=count+1;
									   present_state<=timetolive1;  
			              end if;
			   ---------------------------------------------------------
			   -----protocol for UDP it is 0x11 ------------------------
				-----------------
				---------------------------------------
				when protocol1 => 
				            
				               if count>=7 then
							       packet<=protocol(count);
									 present_state<=headchecksum1;
								    count<=0;
                       else 
                             packet<=protocol(count);								 
			                    count<=count+1;
									   present_state<=protocol1;  
			              end if;
				
				-------------------------------------------------------------------
				--------------head_checksum  ----this will be 16 bits (2 bytes)----
				-------------------------------------------------------------------
				----it will be assigned as zero- in the beginning-------------------
				--------------------------------------------------------------------
				when headchecksum1=>
				               
				           if count>=15 then
							       packet<=headchecksum(count);
									 present_state<=srcip1;
								    count<=0;
                       else 
                             packet<=headchecksum(count);								 
			                    count<=count+1;
									   present_state<=headchecksum1;  
			              end if;
                         								
            when srcip1=>
                       
							  if count>=31 then
							       packet<=srcip(count);
									 present_state<=dstip1;
								    count<=0;
                       else 
                             packet<=srcip(count);								 
			                    count<=count+1;
									   present_state<=srcip1;  
			              end if;		
            
             when dstip1=>
				            
							  if count>=31 then
							       packet<=dstip(count);
									 present_state<=srcport;
								    count<=0;
                       else 
                             packet<=dstip(count);								 
			                    count<=count+1;
									   present_state<=dstip1;  
			              end if;
			   
				when srcport=>
				             if count>=15 then
							       packet<=udpport(count);
									 present_state<=destport;
								    count<=0;
                       else 
                             packet<=udpport(count);								 
			                    count<=count+1;
									   present_state<=srcport;  
			              end if;
								
								
				when destport=>
                       if count>=15 then
							       packet<=udpport(count);
									 present_state<=packetlength1;
								    count<=0;
                       else 
                             packet<=udpport(count);								 
			                    count<=count+1;
									   present_state<=destport;  
			              end if;
				when packetlength1=>

                       if count>=15 then
							       packet<=packetlength(count);
									 present_state<=checksum1;
								    count<=0;
                       else 
                             packet<=packetlength(count);								 
			                    count<=count+1;
									   present_state<=packetlength1;  
			              end if;			
				
				  when checksum1=>
				           if count>=15 then
							       packet<=checksum(count);
									 present_state<=datapayload;
								    count<=0;
                       else 
                             packet<=checksum(count);								 
			                    count<=count+1;
									   present_state<=checksum1;  
			              end if;			
				  
				  
				   when datapayload=>
					        if count>=159 then
							       packet<=payload(count);
									 present_state<=idle;
								    count<=0;
                       else 
                             packet<=payload(count);								 
			                    count<=count+1;
									   present_state<=datapayload;  
			              end if;		
--			   

--			packet1->src_ip[0] = 10;
--			packet1->src_ip[1] = 8;
--			packet1->src_ip[2] = 2;
--			packet1->src_ip[3] = 182;
--
--			packet1->dst_ip[0] = 10;
--			packet1->dst_ip[1] = 8;
--			packet1->dst_ip[2] = 2;
--			packet1->dst_ip[3] = 183;
--              
           
--u16 src_port;
--	u16 dst_port;
--	packet1->src_port = UDP_PORT;    // Source Port
--			packet1->dst_port = UDP_PORT;	 	// Destination Port

--packet1->length = DATALENGTH+8;			// Datagram Length
--		u16 length;	
			
--			u16 checksum;
--	packet1->checksum = 0;			// Data checksum, may not used	
   

		
			when others=> 
                      null;
        end case;							 
                    		  
        

end if;


end process;



crcgen: process(clk)
begin

null;



end process;



end Behavioral;

