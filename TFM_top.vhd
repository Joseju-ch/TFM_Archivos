----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2019 20:35:34
-- Design Name: Jose Juan Cabrera
-- Module Name: TFM_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Top del proyecto
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

entity TFM_top is
Port ( 
           clk100mhz       : in  STD_LOGIC;
           reset           : in  STD_LOGIC;
           
           umb0          : in  STD_LOGIC;
           umb1          : in  STD_LOGIC;
           umb2          : in  STD_LOGIC;
           umb3          : in  STD_LOGIC;
           umb4          : in  STD_LOGIC;
           umb5          : in  STD_LOGIC;
           umb6          : in  STD_LOGIC;
           umb7          : in  STD_LOGIC;
           
           sat0          : in  STD_LOGIC;
           sat1          : in  STD_LOGIC;
           sat2          : in  STD_LOGIC;
           sat3          : in  STD_LOGIC;
           sat4          : in  STD_LOGIC;
           sat5          : in  STD_LOGIC;
           sat6          : in  STD_LOGIC;
           sat7          : in  STD_LOGIC;
           
           LEDsat   : out std_logic_vector(7 downto 0);
           LEDumb   : out std_logic_vector(7 downto 0);
           
           led_mov         : out std_logic;
           btnc            : in  STD_LOGIC;
           btn_imag        : in std_logic;
           
           config_finished : out STD_LOGIC;
           
           vga_hsync : out  STD_LOGIC;
           vga_vsync : out  STD_LOGIC;
           vga_r     : out  STD_LOGIC_vector(3 downto 0);
           vga_g     : out  STD_LOGIC_vector(3 downto 0);
           vga_b     : out  STD_LOGIC_vector(3 downto 0);
           
           ov7670_pclk  : in  STD_LOGIC;
           ov7670_xclk  : out STD_LOGIC;
           ov7670_vsync : in  STD_LOGIC;
           ov7670_href  : in  STD_LOGIC;
           ov7670_data  : in  STD_LOGIC_vector(7 downto 0);
           ov7670_sioc  : out STD_LOGIC;
           ov7670_siod  : inout STD_LOGIC;
           ov7670_pwdn  : out STD_LOGIC;
           ov7670_reset : out STD_LOGIC
    );
end TFM_top;

architecture Behavioral of TFM_top is

---- Generador clk-----------------------------
component generador_clk
    port(
        clk_out1    : OUT std_logic;
        clk_out2    : OUT std_logic;
        reset       : IN std_logic;
        locked      : OUT std_logic;
        clk_in1     : IN std_logic
    );
end component;
-----------------------------------------------
---- Bloque Memoria----------------------------
component bloque_memoria
      PORT (
          clka  : IN STD_LOGIC;
          wea   : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
          addra : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
          dina  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
          clkb  : IN STD_LOGIC;
          addrb : IN STD_LOGIC_VECTOR(18 DOWNTO 0);
          doutb : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
end component;
-----------------------------------------------

---- VGA --------------------------------------
component VGA
    port(
        clk25mhz   : IN std_logic;  
        reset       : IN std_logic;
        hsync       : OUT std_logic;
        vsync       : OUT std_logic; 
        area_activa : OUT std_logic;
        pixel_x : OUT integer;
        pixel_y: OUT integer
    );
end component;
-------------------------------------------------
----- ov7670 Control------------------------------
component ov7670_control
    port(
        clk50mhz        : IN std_logic;
        resend          : IN std_logic;    
        siod            : INOUT std_logic;      
        config_fin      : OUT std_logic;
        sioc            : OUT std_logic;
        reset           : OUT std_logic;
        pwdn            : OUT std_logic;
        xclk            : OUT std_logic
    );
end component;
--------------------------------------------------
---- Captura -------------------------------------
    component ov7670_captura
    port(
        pclk        : IN std_logic;
        vsync       : IN std_logic;
        href        : IN std_logic;
        d           : IN std_logic_vector(7 downto 0);          
        addr        : OUT std_logic_vector(18 downto 0);
        dout        : OUT std_logic_vector(11 downto 0);
        we          : OUT std_logic
    );
end component;
--------------------------------------------------
---- refresco imagen -----------------------------
    component refresco_imagen 
    port(
        clk     : IN std_logic;
        btn     : IN std_logic;
        refres  : OUT std_logic
    );
    end component;
--------------------------------------------------
---- filtrado ------------------------------------
    component filtro_bordes
    port(
        clk100mhz     : in std_logic;
        clk25mhz      : in std_logic;
        reset         : in std_logic;
        area_activa   : in std_logic;
        
       sat0          : in  STD_LOGIC;
       sat1          : in  STD_LOGIC;
       sat2          : in  STD_LOGIC;
       sat3          : in  STD_LOGIC;
       sat4          : in  STD_LOGIC;
       sat5          : in  STD_LOGIC;
       sat6          : in  STD_LOGIC;
       sat7          : in  STD_LOGIC;
               
        salida_filt   : out std_logic_vector(11 downto 0);
        
        LEDsat          : out std_logic_vector(7 downto 0);
        
        rddata1        : in std_logic_vector(11 downto 0);
        addr1          : out std_logic_vector(18 downto 0);
                
        vga_r         : out  STD_LOGIC_vector(3 downto 0);
        vga_g         : out  STD_LOGIC_vector(3 downto 0);
        vga_b         : out  STD_LOGIC_vector(3 downto 0);
        
        pixel_x       : in integer;
        pixel_y       : in integer
    );
    end component;
--------------------------------------------------
---- deteccion_mov -------------------------------
    component deteccion_mov 
      Port ( 
          clk25mhz    : in std_logic;
          reset       : in std_logic; 
          salida_fil  : in std_logic_vector(11 downto 0);
          led_mov     : out std_logic;
          pixel_x, pixel_y : in integer;  
          
          LEDumb        : out std_logic_vector(7 downto 0); 
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
    end component;
--------------------------------------------------
   signal wren       : std_logic_vector(0 downto 0);
   signal resend     : std_logic;
   signal vsync      : std_logic;
   signal nsync      : std_logic;
   
   signal wraddress  : std_logic_vector(18 downto 0);
   signal wrdata     : std_logic_vector(11 downto 0);
   
   signal rdaddr1 : std_logic_vector(18 downto 0);
   signal rddata1   : std_logic_vector(11 downto 0);
   
   signal size_select : std_logic_vector(1 downto 0);
   signal rd_addr,wr_addr  : std_logic_vector(18 downto 0);
   
   signal clk50mhz: std_logic;
   signal clk25mhz: std_logic;
   
   signal area_activa: std_logic;
   signal reset_clk: std_logic;
   
   signal pixel_x, pixel_y: integer;
   
   signal salida_fil: std_logic_vector (11 downto 0);
   
   signal red,gre,blu: std_logic_vector(3 downto 0);
   
      
begin
reset_clk<= not reset;

---- Generador clk ------------------------------
inst_generador_clk: generador_clk
    port map(
        clk_out1    =>clk50mhz,
        clk_out2    =>clk25mhz,
        reset       =>reset_clk,
        locked      =>open,
        clk_in1     =>clk100mhz
    );
-------------------------------------------------
---- Bloque Memoria----------------------------
inst_bloque_memoria: bloque_memoria
      PORT map (
          clka   => ov7670_pclk,
          wea    => wren,
          addra  => wraddress,
          dina   => wrdata,
          clkb   => clk100mhz,
          addrb  => rdaddr1,
          doutb  => rddata1
          );
-------------------------------------------------
---- VGA ----------------------------------------
inst_VGA: VGA
        port map(
            clk25mhz  => clk25mhz,
            reset =>reset,
            hsync  => vga_hsync,
            vsync => vsync,
            area_activa => area_activa,
            pixel_x => pixel_x,
            pixel_y => pixel_y
        );
--------------------------------------------------
vga_vsync<=vsync;
----- ov7670 Control------------------------------
inst_ov7670_control : ov7670_control
    port map(
        clk50mhz        => clk50mhz,
        resend          => resend,
        config_fin      => config_finished,
        sioc            => ov7670_sioc,
        siod            => ov7670_siod,
        reset           => ov7670_reset,
        pwdn            => ov7670_pwdn,
        xclk            => ov7670_xclk
    );
--------------------------------------------------
---- Captura -------------------------------------
inst_ov7670_captura: ov7670_captura 
port map(
    pclk        => ov7670_pclk,
    vsync       => ov7670_vsync,
    href        => ov7670_href,
    d           => ov7670_data,
    addr        => wraddress,
    dout        => wrdata,
    we          => wren(0)
);
--------------------------------------------------
---- refresco imagen -----------------------------
inst_refres_imagen:  refresco_imagen 
    port map(
        clk     => clk25mhz,
        btn     => btnc,
        refres  => resend
    );
--------------------------------------------------
---- filtrado ------------------------------------
inst_filtro_bordes: filtro_bordes
    port map(
        clk100mhz     => clk100mhz,
        clk25mhz      => clk25mhz,
        reset         => reset,
        area_activa   => area_activa,
        salida_filt   => salida_fil,
        LEDsat        => LEDsat,
        sat0          => sat0,
        sat1          => sat1,
        sat2          => sat2,
        sat3          => sat3,
        sat4          => sat4,
        sat5          => sat5,
        sat6          => sat6,
        sat7          => sat7,
        rddata1       => rddata1,
        addr1         => rdaddr1,
        vga_r         => red,
        vga_g         => gre,
        vga_b         => blu,
        pixel_x       => pixel_x,
        pixel_y       => pixel_y
    );
--------------------------------------------------
---- deteccion_mov -----------------------------
inst_deteccion_mov:  deteccion_mov 
    port map(
        clk25mhz     => clk25mhz,
        reset        => reset,
        salida_fil   => salida_fil,
        pixel_x      => pixel_x,
        pixel_y      => pixel_y,
        area_activa  => area_activa, 
        LEDumb       => LEDumb,
        umb0         => umb0,
        umb1         => umb1,
        umb2         => umb2,
        umb3         => umb3,
        umb4         => umb4,
        umb5         => umb5,
        umb6         => umb6,
        umb7         => umb7,
        led_mov      => led_mov
    );
------------------------------------------------

		vga_r <= rddata1(11 downto 8)  when btn_imag='1' and area_activa='1' else red;
        vga_g <= rddata1(7 downto 4)   when btn_imag='1' and area_activa='1' else gre;
        vga_b <= rddata1(3 downto 0)   when btn_imag='1' and area_activa='1' else blu;
        
end Behavioral;