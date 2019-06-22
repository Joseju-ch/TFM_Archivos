----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2019 23:26:09
-- Design Name: Jose Juan Cabrera
-- Module Name: ov7670_control - Behavioral
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

entity ov7670_control is
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

end ov7670_control;

architecture Behavioral of ov7670_control is

---- Regidtro  ------------------------------------
component ov7670_registro
    port(
        clk50mhz : IN std_logic;
        advance  : IN std_logic;          
        resend   : in STD_LOGIC;
        command  : OUT std_logic_vector(15 downto 0);
        acabado  : OUT std_logic
    );
    end component;
---------------------------------------------------
---- I2C ------------------------------------------
component i2c_sender
    port(
        clk50mhz : IN std_logic;
        send  : IN std_logic;
        taken : out std_logic;
        id    : IN std_logic_vector(7 downto 0);
        reg   : IN std_logic_vector(7 downto 0);
        value : IN std_logic_vector(7 downto 0);    
        siod  : INOUT std_logic;      
        sioc  : OUT std_logic
    );
    end component;
---------------------------------------------------
signal sys_clk  : std_logic := '0';    
signal command  : std_logic_vector(15 downto 0);
signal acabado  : std_logic := '0';
signal taken    : std_logic := '0';
signal send     : std_logic;

constant camera_address : std_logic_vector(7 downto 0) := x"42"; -- Device write ID - see top of page 11 of data sheet

begin
    config_fin <= acabado;
    send <= not acabado;
    
--- I2C ------------------------------------------------
	Inst_i2c_sender: i2c_sender port map(
		clk50mhz   => clk50mhz,
		taken => taken,
		siod  => siod,
		sioc  => sioc,
		send  => send,
		id    => camera_address,
		reg   => command(15 downto 8),
		value => command(7 downto 0)
	);
---------------------------------------------------------
	reset <= '1'; 						-- Normal mode
	pwdn  <= '0'; 						-- Power device up
	xclk  <= sys_clk;
---- ov7670 Registro -----------------------------------
	Inst_ov7670_registers: ov7670_registro port map(
		clk50mhz => clk50mhz,
		advance  => taken,
		command  => command,
		acabado  => acabado,
		resend   => resend
	);
---------------------------------------------------------
     
      
	process(clk50mhz)
	begin
		if (clk50mhz'event and clk50mhz='1') then
			sys_clk <= not sys_clk;
		end if;
	end process;

end Behavioral;
