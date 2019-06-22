----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.05.2019 15:29:52
-- Design Name: Jose Juan Cabrera
-- Module Name: deteccion_mov - Behavioral
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

entity deteccion_mov is
  Port ( 
        clk25mhz    : in std_logic;
        reset       : in std_logic; 
        salida_fil  : in std_logic_vector(11 downto 0);
        led_mov     : out std_logic;
        pixel_x, pixel_y : in integer;
        
        LEDumb   : out std_logic_vector(7 downto 0); 
        umb0          : in  STD_LOGIC;
        umb1          : in  STD_LOGIC;
        umb2          : in  STD_LOGIC;
        umb3          : in  STD_LOGIC;
        umb4          : in  STD_LOGIC;
        umb5          : in  STD_LOGIC;
        umb6          : in  STD_LOGIC;
        umb7          : in  STD_LOGIC;

        area_activa : in std_logic
  );
end deteccion_mov;

architecture Behavioral of deteccion_mov is

signal cont_bit_neg1, cont_bit_neg1_s, cont_bit_neg2, cont_bit_neg2_s : integer:=0;

type estado is (contar1,espera500ms,contar2,comparar);
signal estado_a, estado_s: estado;

signal led_mov_s : std_logic;
signal led_reg: std_logic;

signal cont_50ms_s, cont_50ms: integer:=0; --contar 250ms
signal cont_ciclos, cont_ciclos_s: integer;

signal umbral :integer:=40;


begin

umbr:process(umb0, umb1, umb2, umb3, umb4, umb5, umb6, umb7)
begin
    if umb0='1' and umb1='0' and umb2='0' and umb3='0' and umb4 ='0' and umb5='0' and umb6='0' and umb7='0' then
        umbral <= 10;
        LEDumb <= "00000001";
    elsif umb0='1' and umb1='1' and umb2='0' and umb3='0' and umb4 ='0' and umb5='0' and umb6='0' and umb7='0' then
        umbral <= 20;
        LEDumb <= "00000011";
    elsif umb0='1' and umb1='1' and umb2='1' and umb3='0' and umb4 ='0' and umb5='0' and umb6='0' and umb7='0' then
        umbral <= 30;
        LEDumb <= "00000111";
    elsif umb0='1' and umb1='1' and umb2='1' and umb3='1' and umb4 ='0' and umb5='0' and umb6='0' and umb7='0' then
        umbral <= 40;
        LEDumb <= "00001111";
    elsif umb0='1' and umb1='1' and umb2='1' and umb3='1' and umb4 ='1' and umb5='0' and umb6='0' and umb7='0' then
        umbral <= 50;
        LEDumb <= "00011111";
    elsif umb0='1' and umb1='1' and umb2='1' and umb3='1' and umb4 ='1' and umb5='1' and umb6='0' and umb7='0' then
        umbral <= 70;
        LEDumb <= "00111111";
    elsif umb0='1' and umb1='1' and umb2='1' and umb3='1' and umb4 ='1' and umb5='1' and umb6='1' and umb7='0' then
        umbral <= 90;
        LEDumb <= "01111111";
    elsif umb0='1' and umb1='1' and umb2='1' and umb3='1' and umb4 ='1' and umb5='1' and umb6='1' and umb7='1' then
        umbral <= 120;
        LEDumb <= "11111111";
    else
        umbral <= 40;
        LEDumb <= "00001111";
    end if;
end process;


detec:process(clk25mhz, reset)
begin
    if reset='0' then
        cont_bit_neg1<=0;
        cont_bit_neg2<=0;
        estado_a<=contar1;
        led_reg<='0';
        led_mov<='0';
        cont_50ms<=0;
        cont_ciclos<=0;
        
    elsif clk25mhz'event and clk25mhz='1' then
        cont_bit_neg1<=cont_bit_neg1_s;
        cont_bit_neg2<=cont_bit_neg2_s;
        estado_a<=estado_s;
        led_reg<=led_mov_s;
        led_mov<=led_mov_s;
        cont_50ms<=cont_50ms_s;
        cont_ciclos<= cont_ciclos_s;
        
    end if;
end process;


process(estado_a,cont_50ms, cont_bit_neg1, cont_bit_neg2, led_reg, cont_ciclos, area_activa, pixel_x, pixel_y,
        salida_fil, estado_s, umbral)
begin
    estado_s<=estado_a;
    cont_50ms_s<= cont_50ms;
    cont_bit_neg1_s<=cont_bit_neg1;
    cont_bit_neg2_s<=cont_bit_neg2;
    led_mov_s<=led_reg;
    cont_ciclos_s<=cont_ciclos;
    
    case estado_a is
    when contar1 => 
        if area_activa='1' and pixel_x= and pixel_y=0 then
            cont_bit_neg1_s<=1; -- bit 0,0 es negro

        elsif area_activa='1' and pixel_y*pixel_x<307200 then

            if salida_fil="111111111111" then
                cont_bit_neg1_s<=cont_bit_neg1+1;
            end if;
        elsif pixel_x*pixel_y>=307200 then
            estado_s<=espera500ms;
            cont_ciclos_s<=0;

        end if;           

        
    when espera500ms => -----------------
        if cont_ciclos<11 then  
            if cont_50ms<1250000 then--0.05/(1/25000000)=1250000
                cont_50ms_s<=cont_50ms+1;
            elsif cont_50ms>=1250000 then
                cont_ciclos_s<=cont_ciclos+1;
                cont_50ms_s<=0;
            end if;
        elsif cont_ciclos>=11 then
            estado_s<=contar2;
        end if;
        
    when contar2 =>

        if area_activa='1' and pixel_x=0 and pixel_y=0 then
            cont_bit_neg2_s<=1; -- bit 0,0 es negro

        elsif area_activa='1' and pixel_y*pixel_x<307200 then

            if  salida_fil="111111111111" then
                cont_bit_neg2_s<=cont_bit_neg2+1;
            end if;

            
        elsif  pixel_x*pixel_y>=307200 then
            estado_s<=comparar;
        end if; 
            
    when comparar =>
        if (abs(cont_bit_neg1-cont_bit_neg2) > umbral) then 
            led_mov_s<='1';
        else 
            led_mov_s<='0';
        end if;
        estado_s<=contar1;
        cont_bit_neg1_s<=0;
        cont_bit_neg2_s<=0;
            
    when others =>
        estado_s<=contar1;
    end case;

end process;

end Behavioral;
