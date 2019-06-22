----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.05.2019 12:12:41
-- Design Name: Jose Juan Cabrera
-- Module Name: refresco_imagen - Behavioral
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

entity refresco_imagen is
    port(
        clk     : IN std_logic;
        btn     : IN std_logic;
        refres  : OUT std_logic
    );
end refresco_imagen;

architecture Behavioral of refresco_imagen is
    signal cont: unsigned(23 downto 0);
begin
	process(clk)
    begin
        if (clk'event and clk='1') then
            if btn = '1' then
                if cont = X"FFFFFF" then
                    refres <= '1';
                else
                    refres <= '0';
                end if;
                cont <= cont+1;
            else
                cont <= (others => '0');
                refres <= '0';
            end if;
        end if;
end process;

end Behavioral;
