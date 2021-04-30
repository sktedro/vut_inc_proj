-- uart.vhd: UART controller - receiving part
-- Author(s): xskalo01
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK: 	     in  std_logic;
	RST: 	     in  std_logic;
	DIN: 	     in  std_logic;
	DOUT: 	    out std_logic_vector(7 downto 0) := "00000000";
	DOUT_VLD: 	out std_logic := '0'
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
  --Counting to 16 or 24
  signal CT1       : std_logic_vector(4 downto 0) := "00000";
  --Counting to 8 (for receival of the bits)
  signal CT2       : std_logic_vector(3 downto 0) := "0000";
  --Vector containing the FSM's state
  signal state_vec : std_logic_vector(1 downto 0);
begin
  
    import : entity work.UART_FSM(behavioral)
    port map (
        CLK 	     => CLK,
        RST 	     => RST,
        DIN 	     => DIN,
        CT1       => CT1,
        CT2       => CT2,
        state_vec => state_vec
    );
    
    process (CLK) begin 
      if rising_edge(CLK) then
        
        --CT1 only counts to 24
        if CT1 = "10110" then 
          CT1 <= "00000";
        --But when reading, it counts to 16
        elsif CT1 = "01111" and state_vec = "10" then 
          CT1 <= "00000";
        --Reset when the first bit arrives
        elsif DIN = '0' and state_vec = "00" then 
          CT1 <= "00000";
        --Otherwise, increment at every rising_edge
        else
          CT1 <= CT1 + 1; 
        end if;
        
        
        --When 8 bits are received, reset
        if CT2 = "1000" then 
          CT2 <= "0000";
        --Otherwise, when receiving, increment at every 16th CLK
        elsif state_vec = "10" and CT1 = "01111" then 
          CT2 <= CT2 + 1;
        end if;
        
        
        --If we are in 'receiving' state
        if state_vec = "10" then 
          --8 times in total, everytime the CT1 is zero, write DIN to DOUT
          if CT1 = "00000" and unsigned(CT2) < 8 then
            DOUT(to_integer(unsigned(CT2))) <= DIN;
          end if;
        end if;
        
        
        --On the last clock cycle of the stop bit, set DOUT_VLD to one
        if state_vec = "11" and CT1 = "00110" and CT2 = "0000" then 
          DOUT_VLD <= '1';
        else
        --Otherwise it should be zero
          DOUT_VLD <= '0';
        end if;
        
        
        --After the stop bit, reset the DOUT
        --if state_vec = "00" then
          --DOUT <= "00000000";
        --end if;
        
      end if;
    end process;
end behavioral;





