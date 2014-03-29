library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity relojTB is
end relojTB;

architecture archTB of relojTB is
	
	component Reloj is
	port (
		clk  : in std_logic;
		rst  : in std_logic;
		b1   : in std_logic;
		b2   : in std_logic;
		mode : in std_logic;
		
		modo     : out std_logic_vector(1 downto 0);
		horas    : out std_logic_vector(5 downto 0);
		minutos  : out std_logic_vector(6 downto 0);
		segundos : out std_logic_vector(6 downto 0);
		sigAlarm : out std_logic 
		);
	end component;
		
	signal clk  : std_logic;
	signal rst  : std_logic;
	signal b1   : std_logic;
	signal b2   : std_logic;
	signal mode : std_logic;
	
	signal modo     : std_logic_vector(1 downto 0);
	signal horas    : std_logic_vector(5 downto 0);
	signal minutos  : std_logic_vector(6 downto 0);
	signal segundos : std_logic_vector(6 downto 0);
	signal sigAlarm : std_logic;
	
	begin
		
		relojPrueba : Reloj
		port map(
			clk  => clk,
			rst  => rst,
			b1   => b1,
			b2   => b2,
			mode => mode,
			
			modo     => modo,
			horas    => horas,
			minutos  => minutos,
			segundos => segundos,
			
			sigAlarm => sigAlarm
		);
		
		generadorReloj : process is
		begin
			clk <= '0';
      		wait for 1000 ms;
      		clk <= '1';
      		wait for 1000 ms;
      	end process;
      	
end archTB;

			
			
			
			