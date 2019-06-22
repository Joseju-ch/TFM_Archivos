----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.05.2019 22:09:36
-- Design Name: Jose Juan Cabrera
-- Module Name: filtro_bordes - Behavioral
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

entity filtro_bordes is
  Port (
      clk100mhz     : in std_logic;
      clk25mhz      : in std_logic;
      reset         : in std_logic;
      area_activa   : in std_logic;
      
      salida_filt   : out std_logic_vector(11 downto 0);
      LEDsat        : out std_logic_vector(7 downto 0);
      
      rddata1        : in std_logic_vector(11 downto 0);
      addr1          : out std_logic_vector(18 downto 0);

       sat0          : in  STD_LOGIC;
       sat1          : in  STD_LOGIC;
       sat2          : in  STD_LOGIC;
       sat3          : in  STD_LOGIC;
       sat4          : in  STD_LOGIC;
       sat5          : in  STD_LOGIC;
       sat6          : in  STD_LOGIC;
       sat7          : in  STD_LOGIC;
      
      vga_r         : out  STD_LOGIC_vector(3 downto 0);
      vga_g         : out  STD_LOGIC_vector(3 downto 0);
      vga_b         : out  STD_LOGIC_vector(3 downto 0);
      
      pixel_x       : in integer;
      pixel_y       : in integer
  );
end filtro_bordes;

architecture Behavioral of filtro_bordes is
    
    signal mascara11: integer:= -1 ;
    signal mascara12: integer:= -1 ;
    signal mascara13: integer:= -1 ;
    signal mascara21: integer:= -1 ;
    signal mascara22: integer:= 8 ;
    signal mascara23: integer:= -1 ;
    signal mascara31: integer:= -1 ;
    signal mascara32: integer:= -1 ;
    signal mascara33: integer:= -1 ;
    ----------------------------------------------------
    -- mascara11, mascara12, mascara13      -1   -1   -1  
    -- mascara21, mascara22, mascara23      -1    8   -1   
    -- mascara31, mascara32, mascara33      -1   -1   -1  
    ----------------------------------------------------
    signal suma_pesos: integer:= 1;     -- suma de los pesos de cada bit
    
    signal bit11, bit12, bit13: std_logic_vector(11 downto 0):=("000000000000");
    signal bit21, bit22, bit23: std_logic_vector(11 downto 0):=("000000000000");
    signal bit31, bit32, bit33: std_logic_vector(11 downto 0):=("000000000000");
    
    signal bit11_s, bit12_s, bit13_s: std_logic_vector(11 downto 0):=("000000000000");
    signal bit21_s, bit22_s, bit23_s: std_logic_vector(11 downto 0):=("000000000000");
    signal bit31_s, bit32_s, bit33_s: std_logic_vector(11 downto 0):=("000000000000");
    
    signal bit13_reg, bit23_reg, bit33_reg: std_logic_vector(11 downto 0):=("000000000000");
    
    signal salida: std_logic_vector(11 downto 0);
    
    type estado is (idle, borde_sup,central,borde_inf);
    signal estado_a, estado_s: estado;
    
    signal flag_leer: std_logic:='0';
    
    signal full1, full2, full3 : std_logic;
    
    signal cont, cont_s : integer:=0;
    
    signal saturacion : integer:=0;
begin    
        
    fifo_proc: process(rddata1, clk100mhz)
    begin
        if clk100mhz'event and clk100mhz='1' then

            addr1<=(others=>'Z');
            cont_s<=cont;
   
            if flag_leer='1' then
                if cont=0 then
                    addr1<=std_logic_vector(to_unsigned(((640*pixel_y-1)+pixel_x+2),19));
                    cont_s<=cont+1;
                    bit13_reg <= rddata1;
                elsif cont=1 then
                    addr1<=std_logic_vector(to_unsigned(((640*(pixel_y))+pixel_x+2),19));
                    cont_s<=cont+1;
                    bit23_reg <= rddata1;
                elsif cont=2 then
                    addr1<=std_logic_vector(to_unsigned(((640*(pixel_y+1))+pixel_x+2),19));
                    cont_s<=cont+1;
                    bit33_reg <= rddata1;
                end if;
            end if;
        end if;
    end process;  
    
    
    satur:process(sat0, sat1,sat2, sat3, sat4, sat5, sat6, sat7)
    begin
        if sat0='1' and sat1='0' and sat2='0' and sat3='0' and sat4 ='0' and sat5='0' and sat6='0' and sat7='0' then
            saturacion <= 0;
            LEDsat <= "10000000";
        elsif sat0='1' and sat1='1' and sat2='0' and sat3='0' and sat4 ='0' and sat5='0' and sat6='0' and sat7='0' then
            saturacion <= 2;
            LEDsat <= "11000000";
        elsif sat0='1' and sat1='1' and sat2='1' and sat3='0' and sat4 ='0' and sat5='0' and sat6='0' and sat7='0' then
            saturacion <= 4;
            LEDsat <= "11100000";
        elsif sat0='1' and sat1='1' and sat2='1' and sat3='1' and sat4 ='0' and sat5='0' and sat6='0' and sat7='0' then
            saturacion <= 6;
            LEDsat <= "11110000";
        elsif sat0='1' and sat1='1' and sat2='1' and sat3='1' and sat4 ='1' and sat5='0' and sat6='0' and sat7='0' then
            saturacion <= 8;
            LEDsat <= "11111000";
        elsif sat0='1' and sat1='1' and sat2='1' and sat3='1' and sat4 ='1' and sat5='1' and sat6='0' and sat7='0' then
            saturacion <= 10;
            LEDsat <= "11111100";
        elsif sat0='1' and sat1='1' and sat2='1' and sat3='1' and sat4 ='1' and sat5='1' and sat6='1'  and sat7='0' then
            saturacion <= 12;
            LEDsat <= "11111110";
        elsif sat0='1' and sat1='1' and sat2='1' and sat3='1' and sat4 ='1' and sat5='1' and sat6='1' and sat7='1' then
            saturacion <= 14;
            LEDsat <= "11111111";
        else
            saturacion <= 8;
            LEDsat <= "11111000";
        end if;
    end process;
    
    salida_proc: process(clk25mhz)
    begin
        if clk25mhz'event and clk25mhz='1' then
            if area_activa='1' then
                    if (((to_integer(unsigned(salida(11 downto 8)))+to_integer(unsigned(salida(7 downto 4)))+to_integer(unsigned(salida(3 downto 0))))/3)>=saturacion) then
                      vga_r <= "1111";
                      vga_g <= "1111";
                      vga_b <= "1111";
                      salida_filt <="111111111111";
                    else
                      vga_r <= "0000";
                      vga_g <= "0000";
                      vga_b <= "0000";
                      salida_filt <="000000000000";
                    end if;
            else 
                 vga_r <= "0000" ;
                 vga_g <= "0000"  ;
                 vga_b <= "0000"  ;
                 salida_filt <="000000000000";

            end if;
        end if;
    end process;
    
    registros: process (clk25mhz, reset)
    begin
        if reset='0' then
            bit11 <=(others=>'0');
            bit12 <=(others=>'0');
            bit13 <=(others=>'0');
            bit21 <=(others=>'0');
            bit22 <=(others=>'0');
            bit23 <=(others=>'0');
            bit31 <=(others=>'0');
            bit32 <=(others=>'0');
            bit33 <=(others=>'0');
            estado_a <= idle;
        elsif clk25mhz'event and clk25mhz='1' then
            if flag_leer='1' then
                estado_a <= estado_s;
                bit11 <=bit11_s;
                bit12 <=bit12_s;
                bit13 <=bit13_reg;
                bit21 <=bit21_s;
                bit22 <=bit22_s;
                bit23 <=bit23_reg;
                bit31 <=bit31_s;
                bit32 <=bit32_s;
                bit33 <=bit33_reg;
            else
                estado_a <= estado_s;
                bit11 <=bit11_s;
                bit12 <=bit12_s;
                bit13 <=bit13_s;
                bit21 <=bit21_s;
                bit22 <=bit22_s;
                bit23 <=bit23_s;
                bit31 <=bit31_s;
                bit32 <=bit32_s;
                bit33 <=bit33_s;
            end if;
        end if;
    end process;
    

esquina: process(pixel_x, pixel_y, estado_a, bit11, bit12, bit13, bit21, bit22, bit23, bit31, bit32, bit33,
                    area_activa, rddata1, mascara11, mascara12, mascara13, mascara21, mascara22, 
                    mascara23, mascara31, mascara32, mascara33, suma_pesos)--,dout1, dout2, dout3)
    begin
    flag_leer<='0';
    
    estado_s <=estado_a;
        
    salida<="000000000000";
    
    bit11_s <=bit11;
    bit12_s <=bit12;
    bit13_s <=bit13;
    bit21_s <=bit21;
    bit22_s <=bit22;
    bit23_s <=bit23;
    bit31_s <=bit31;
    bit32_s <=bit32;
    bit33_s <=bit33;
    
    case estado_a is
    when idle =>
        if  pixel_y=0  then 
            estado_s<=borde_sup;
        end if;
        
    when borde_sup =>
        salida <= "000000000000";
        if pixel_x>=641 then 
            estado_s<=central;
        end if;
        
    when central =>
        salida<="000000000000";
        if pixel_x=798 then
            --leer columna 0
                bit11_s <=bit12;
                bit12_s <=bit13;
                bit21_s <=bit22;
                bit22_s <=bit23;
                bit31_s <=bit32;
                bit32_s <=bit33;
                
                flag_leer<='1';
                
                cont_s<=0;
 -------------------------------
        elsif pixel_x=799 then
            --leer columna 1
                bit11_s <=bit12;
                bit12_s <=bit13;
                bit21_s <=bit22;
                bit22_s <=bit23;
                bit31_s <=bit32;
                bit32_s <=bit33;
                
                flag_leer<='1';
                
                cont_s<=0;
                
        ---------------------
        elsif pixel_x=0 then
            --leer columna 2;
            salida<="000000000000";
            
                bit11_s <=bit12;
                bit12_s <=bit13;
                bit21_s <=bit22;
                bit22_s <=bit23;
                bit31_s <=bit32;
                bit32_s <=bit33;
                
                flag_leer<='1';
                
                cont_s<=0;
                
    ---------------------
        elsif pixel_x>0 and pixel_x<(640-1) then
            --leer columna sig
                
                bit11_s <=bit12;
                bit12_s <=bit13;
                bit21_s <=bit22;
                bit22_s <=bit23;
                bit31_s <=bit32;
                bit32_s <=bit33;
                
                flag_leer<='1';
                
                salida<=std_logic_vector(to_unsigned(((to_integer((unsigned(bit11))*mascara11)+to_integer((unsigned(bit12))*mascara12)+to_integer((unsigned(bit13))*mascara13)+to_integer((unsigned(bit21))*mascara21)+to_integer((unsigned(bit22))*mascara22)+to_integer((unsigned(bit23))*mascara23)+to_integer((unsigned(bit31))*mascara31)+to_integer((unsigned(bit32))*mascara32)+to_integer((unsigned(bit33))*mascara33))/(suma_pesos)),12));

                cont_s<=0;
---------------------
       elsif pixel_x>=640-1  then
           salida<="000000000000";    
       end if;
       
       if pixel_y=480-1 then
            estado_s<=borde_inf;
       end if;
       
    when borde_inf =>
        salida <= "000000000000";
        if pixel_x>640 then 
            estado_s<=idle;
        end if;
    when others =>
        estado_s<=idle;
    end case;
end process;  
end Behavioral;
