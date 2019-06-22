----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.05.2019 09:54:06
-- Design Name: Jose Juan Cabrera
-- Module Name: ov7670_captura - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ov7670_captura is
    Port ( 
           pclk  : in   STD_LOGIC;
           vsync : in   STD_LOGIC;
           href  : in   STD_LOGIC;
           d     : in   STD_LOGIC_VECTOR (7 downto 0);
           addr  : out  STD_LOGIC_VECTOR (18 downto 0);
           dout  : out  STD_LOGIC_VECTOR (11 downto 0);
           we    : out  STD_LOGIC);
end ov7670_captura;

architecture Behavioral of ov7670_captura is
    signal d_latch      : std_logic_vector(15 downto 0) := (others => '0');
    signal address      : STD_LOGIC_VECTOR(18 downto 0) := (others => '0');
    signal href_last    : std_logic_vector(6 downto 0)  := (others => '0');
    signal we_reg       : std_logic := '0';
    signal href_hold    : std_logic := '0';
    signal latched_vsync : STD_LOGIC := '0';
    signal latched_href  : STD_LOGIC := '0';
    signal latched_d     : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    ----------------------
    signal cont: integer:=0;
    signal ciclos: integer:=0;
    ------------------------
begin
    addr <= address;
    we <= we_reg;
    dout   <= d_latch(15 downto 12) & d_latch(10 downto 7) & d_latch(4 downto 1); 
 --------------------------------   
    datos: process(pclk,cont, ciclos, we_reg)
    begin
        if pclk'event and pclk='1' then
            if cont >= 640 and ciclos <= 960 and we_reg='1' then
                address <= std_logic_vector(unsigned(address)+1);
            end if;
            
            
            if (cont rem 640)+1 = 640 then
                ciclos <= ciclos+1;
            end if;
            
            
            if cont = 0 then
                ciclos<= 0;
                address <= (others => '0');
            end if;
        end if;
    end process;
    
    capture_process: process(pclk)
    begin
       if (pclk'event and pclk='1') then
          if we_reg = '1' then
          
               cont <= cont+1;
          end if;
          href_hold <= latched_href;
          

          -- capturing the data from the camera, 12-bit RGB
          if latched_href = '1' then
             d_latch <= d_latch( 7 downto 0) & latched_d;
          end if;
          we_reg  <= '0';
    
          -- Is a new screen about to start (i.e. we have to restart capturing
          if latched_vsync = '1' then 
             cont <= 0;
             href_last    <= (others => '0');
          else
            if href_last(0)='1' then
                we_reg <= '1';
                href_last <= (others => '0');
            else 
                href_last <= href_last(href_last'high-1 downto 0) & latched_href;
            end if;
          end if;
       end if;
       if (pclk'event and pclk='1') then
          latched_d     <= d;
          latched_href  <= href;
          latched_vsync <= vsync;
       end if;
    end process;
end Behavioral;
