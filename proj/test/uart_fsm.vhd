-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): xskalo01
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-------------------------------------------------
entity UART_FSM is
port(
  CLK       : in std_logic;
  RST       : in std_logic;
  DIN       : in std_logic;
  CT1       : in std_logic_vector(4 downto 0); --Waiting for 24 clock cycles
  CT2       : in std_logic_vector(3 downto 0);  --Waiting for the end of the stop bit
  state_vec : out std_logic_vector(1 downto 0) --Saving the state
  );
end entity UART_FSM;
-------------------------------------------------
architecture behavioral of UART_FSM is
  type STATE_TYPE is (WAIT_FOR_STARTBIT, WAIT_FOR_FIRSTBIT, RECEIVING, FINISH);
    --                00                 01                 10         11
  signal state : STATE_TYPE := WAIT_FOR_STARTBIT; 
begin
  
  process(CLK) begin
    if rising_edge(CLK) then
      
      --Reset the state
      if RST = '1' then
        state <= WAIT_FOR_STARTBIT;
        state_vec <= "00";
      else
        case state is
          --If start bit arrives, wait for the first bit (8 + 16 clk cycles)
          when WAIT_FOR_STARTBIT => if DIN = '0' then
                                      state <= WAIT_FOR_FIRSTBIT;
                                      state_vec <= "01";
                                    end if;
          --When we are in the middle of the first bit, start receiving
          when WAIT_FOR_FIRSTBIT => if CT1 = "10110" then
                                      state <= RECEIVING;
                                      state_vec <= "10";
                                    end if;
          --When 8 bits were received, wait for the end of the stop bit
          when RECEIVING => if CT2 = "1000" then
                              state <= FINISH;
                              state_vec <= "11";
                            end if;
          --When transmission ends, reset the state and wait for the next start bit
          when FINISH => if CT1 = "00110" then
                            state <= WAIT_FOR_STARTBIT;
                            state_vec <= "00";
                          end if;
          when others => null;
        end case;
        
      end if;
    end if;
  end process;
end behavioral;






