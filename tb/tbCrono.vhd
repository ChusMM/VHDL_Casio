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
		horas    : out std_logic_vector(4 downto 0);
		minutos  : out std_logic_vector(5 downto 0);
		segundos : out std_logic_vector(5 downto 0);
		sigAlarm : out std_logic 
		);
	end component;
		
	signal clk  : std_logic;
	signal rst  : std_logic;
	signal b1   : std_logic;
	signal b2   : std_logic;
	signal mode : std_logic;
	
	signal modo     : std_logic_vector(1 downto 0);
	signal horas    : std_logic_vector(4 downto 0);
	signal minutos  : std_logic_vector(5 downto 0);
	signal segundos : std_logic_vector(5 downto 0);
	signal sigAlarm : std_logic;
	
begin -- test
		
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
      	wait for 500 ms;
      	clk <= '1';
      	wait for 500 ms;
    end process;
    
    pruebaCrono : process is
    begin
    	-- Ver hora (Por defecto)
    	wait for 3000 ms;
    	-- Ver crono
    	mode <= '1';
    	wait for 1000 ms;
    	mode <= '0';
    	wait for 1000 ms;
    	-- Resetear crono
    	b1 <= '1';
    	wait for 1000 ms;
    	b1 <= '0';
    	wait for 1000 ms;
    	-- Encender crono
    	b2 <= '1';
    	wait for 1000 ms;
    	b2 <= '0';
    	wait for 5000 ms;
    	-- Ver configuracion alarma
    	mode <= '1';
    	wait for 1000 ms;
    	mode <= '0';
    	wait for 1000 ms;
    	-- Ver hora;
    	mode <= '1';
    	wait for 1000 ms;
    	mode <= '0';
    	wait for 1000 ms;
    	-- Volver a ver crono
    	mode <= '1';
    	wait for 1000 ms;
    	mode <= '0';
    	wait for 1000 ms;
    	-- Parar crono
    	b2 <= '1';
    	wait for 1000 ms;
    	b2 <= '0';
    	wait for 2000 ms;
    	-- volver a Encender crono
    	b2 <= '1';
    	wait for 1000 ms;
    	b2 <= '0';
    	wait for 3000 ms;
    	-- Resetear Crono;
    	b1 <= '1';
    	wait for 1000 ms;
    	b1 <= '0';
    	wait for 2000 ms;
    	-- Iniciar crono
    	b2 <= '1';
    	wait for 1000 ms;
    	b2 <= '0';
    	wait for 2000 ms;
    	-- Modo alarma
    	mode <= '1';
    	wait for 1000 ms;
    	mode <= '0';
    	wait for 1000 ms;
    	-- Modo ver hora
    	mode <= '1';
    	wait for 1000 ms;
    	mode <= '0';
    	
    end process;
   
end archTB;
	