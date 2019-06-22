----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2019 18:49:50
-- Design Name: Jose Juan Cabrera
-- Module Name: VGA - Behavioral
-- Project Name: TFM_VHDL
-- Target Devices: 
-- Tool Versions: 
-- Description: Controldaro VGA
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


entity VGA is
    Port ( 
   	    clk25mhz    : IN std_logic;  
        reset 		: IN std_logic;  
        hsync       : OUT std_logic;
        vsync       : OUT std_logic;
        area_activa: OUT std_logic;
        
        pixel_x: out integer;
        pixel_y: out integer
    );	
end VGA;

architecture Behavioral of VGA is

    -- VGA 640 - 480 sincronizador 60Hz
    constant HD: integer:=640; 
    constant HF: integer:=16 ; 
    constant HB: integer:=48 ; 
    constant HR: integer:=96 ;
    constant HM: integer:=799;	
    
    constant VD: integer:=480;
    constant VF: integer := 10;
    constant VB: integer:=33;  
    constant VR: integer:= 2; 
    constant VM: integer :=524;

    signal h_cont:integer:=0;		
    signal v_cont:integer:=0;


begin

	proc_area_act: process(Clk25mhz,reset)
		begin
		    if reset='0' then
		        h_cont<=0;
		        v_cont<=0;
			elsif (Clk25mhz'event and Clk25mhz='1') then
				if (h_cont = HM) then
					h_cont <= 0;
                if (v_cont = VM) then
                    v_cont <= 0;
                    area_activa <= '1';
                else
                     if (v_cont < (480-1)) then
                        area_activa <= '1';
                     end if;
                     v_cont <= v_cont+1;
               end if;
				else
                  if (h_cont = (640-1)) then
                     area_activa <= '0';
                  end if;
					h_cont <= h_cont + 1;
				end if;
			end if;
		end process;
		
    pixel_x <= h_cont;
    pixel_y <= v_cont;

	h_sync: process(Clk25mhz,reset)
		begin
		    if reset='0' then
		        hsync<='0';
			elsif (Clk25mhz'event and Clk25mhz='1') then
				if (h_cont >= (HD+HF) and h_cont <= (HD+HF+HR-1)) then   -- 656 751
					hsync <= '0';
				else
					hsync <= '1';
				end if;
			end if;
		end process;

	v_sync: process(Clk25mhz,reset)
		begin
		    if reset='0' then
		        vsync<='0';
			elsif (Clk25mhz'event and Clk25mhz='1') then
				if (v_cont >= (VD+VF) and v_cont <= (VD+VF+VR-1)) then  -- 490  491
					vsync <= '0';
				else
					vsync <= '1';
				end if;
			end if;
		end process;
end Behavioral;