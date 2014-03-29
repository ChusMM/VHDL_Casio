library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Reloj is
	
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
		
end Reloj;

architecture archReloj of Reloj is
	
	type estados is (verHora, cronometro, confAlarma, confHora);
	type modoVisualizacionHora is (m12, m24);
	type estCrono is (parado, enMarcha, reinicio);
	type estAlarma is (alarmOn, alarmOff);
	
	-- Estado del relojo
	signal estado          : estados := verHora;
	signal estadoSiguiente : estados;
	
	-- Formato de visualizacion de la hora
	signal modoHora : modoVisualizacionHora := m24;
	signal modoHoraAnterior : modoVisualizacionHora := m24;
	
	-- Estado del cronometro
	signal estadoCrono : estCrono := parado;
	
	-- Estado de la alarma
	signal estadoAlarma : estAlarma := alarmOff;
	
	-- am o pm, Si am == 0 => pm 
	signal am      : std_logic := '1';
	signal amAlarm : std_logic := '1';
	
	-- Hora del día	
	signal horaActual       : natural range 0 to 24;
	signal minutosActuales  : natural range 0 to 59;
	signal segundosActuales : natural range 0 to 59;
	
	-- Cuenta del cronómetro
	signal horasCronometro    : natural range 0 to 24;
	signal minutosCronometro  : natural range 0 to 59;
	signal segundosCronometro : natural range 0 to 59;
	
	-- Hora de la alarma
	signal horaAlarma    : natural range 0 to 24;
	signal minutoAlarma  : natural range 0 to 59;
	signal segundoAlarma : natural range 0 to 59;
			
begin -- Inicio de la lógica
	
	-- Hardware secuencial que controla la hora actual.
	secHora : process(clk, rst, modoHora, b1, b2)
	begin
		
		if(rst = '1') then
			am     <= '1';
			estado <= verHora;
			
			horaActual       <= 0;
			minutosActuales  <= 0;
			segundosActuales <= 0;
			
		elsif(clk'event and clk = '1') then		
			
			estado <= estadoSiguiente;
			
			-- Conviene que el cambio de formato la hora y el conteo de horas sean 
		    -- secuencias disjuntos porque afectan a las mismas señales.
						
			if modoHoraAnterior /= modoHora then -- Si se ha cambiado el formato
				
				if modoHora = m12 then           -- *** Pasar a formato 12h ***
					
					if horaActual > 12 then      -- Si son más de las 12 del mediodia
						horaActual <= horaActual - 12;
					elsif horaActual = 0 then    -- Si son las 12 de la noche   
						horaActual <= 12;
					else                         -- Otro caso
						horaActual <= horaActual;
					end if;
					
					modoHoraAnterior <= modoHora;
				else    					  -- *** Pasar al formato 24h ***
					
					if am = '0' then          -- Si estamos después del mediodía
						if horaActual /= 12 then
							horaActual <= horaActual + 12;
						else
							horaActual <= horaActual;
						end if;
					else
						if horaActual = 12 then -- Si son las 12 de la madrugada
							horaActual <= 0;
						else
							horaActual <= horaActual;
						end if;
					end if;
					
					modoHoraAnterior <= modoHora;
				end if;
			
			elsif b1 = '1' and b2 /= '1' and estado = confHora then
			-- Si estamos en modo configuracion y pulsamos b1, incrementa hrs.
			-- Aunque estemos en el modo configuracion, la hora siue corriendo.

				case modoHora is         -- Configurar la hora a mostrar
				when m24 =>	             -- En modo 24h
						
					if horaActual = 23 then
						horaActual <= 0;
						am <= '1';          -- Pasar a la madrugada
					else
						horaActual <= horaActual + 1;

						if horaActual = 11 then
							am <= '0';      -- Pasar a la tarde
						else
							am <= am;
						end if;							
					end if;
												
				when m12 =>                 -- En modo 12h
					if horaActual = 12 then -- Si son las 12 paso a la 1
						horaActual <= 1;
					else
						horaActual <= horaActual + 1;
							
						if horaActual = 11 then
							if am = '1' then -- Si son las 12 pm
								am <= '0';   -- Paso a la tarde
							else             -- Si estamos en la tarde
								am <= '1';   -- Paso a la madrugada
							end if;
						else
							am <= am;        -- Control señales
						end if;
					end if;
	
				when others =>               -- Control señales
					am         <= am;
					horaActual <= horaActual;
				end case;
				
			elsif b2 = '1' and b1 /= '1' and estado = confHora then
				
				minutosActuales <= minutosActuales + 1;
			
				if minutosActuales = 59 then
					minutosActuales <= 0;
				end if;

			else 
				-- En cualquier otro caso se actualiza la hora
				
				-- Conteo de horas, minutos y segundos de la hora del día
				if segundosActuales = 59 then     -- Nueva cuenta de segundos
					segundosActuales <= 0;
					
					if minutosActuales = 59 then  -- Nueva cuenta de minutos
						minutosActuales <= 0;    -- Nueva hora
					
						case modoHora is         -- Configurar la hora a mostrar
						when m24 =>	             -- En modo 24h
						
							if horaActual = 23 then
								horaActual <= 0;
								am <= '1';          -- Pasar a la madrugada
							else
								horaActual <= horaActual + 1;

								if horaActual = 11 then
									am <= '0';      -- Pasar a la tarde
								else
									am <= am;
								end if;							
							end if;					
						
						when m12 =>                 -- En modo 12h
							if horaActual = 12 then -- Si son las 12 paso a la 1
								horaActual <= 1;
							else
								horaActual <= horaActual + 1;
							
								if horaActual = 11 then
									if am = '1' then -- Si son las 12 pm
										am <= '0';   -- Paso a la tarde
									else             -- Si estamos en la tarde
										am <= '1';   -- Paso a la madrugada
									end if;
								else
									am <= am;        -- Control señales
								end if;
							end if;
	
						when others =>               -- Control señales
							am         <= am;
							horaActual <= horaActual;
						end case;	
					else                             -- Control señales
						am 				<= am;
						horaActual      <= horaActual;
						minutosActuales <= minutosActuales + 1;						
					end if;
				else                                 -- Control señales
					horaActual       <= horaActual;
					minutosActuales  <= minutosActuales;
					segundosActuales <= segundosActuales + 1;
				end if;
			end if;		
		end if;
			
	end process;
	
	-- Hardware secuencial que controla el cronometro
	secCrono : process(clk, rst, estadoCrono)
	begin
		if(rst = '1') then
					
			horasCronometro    <= 0;
			minutosCronometro  <= 0;
			segundosCronometro <= 0;
			
		elsif(clk'event and clk = '1') then
		
			if estadoCrono = enMarcha then       -- Crono en marcha
				
				if segundosCronometro = 59 then   -- Nueva cuenta de segundos
					segundosCronometro <= 0;
					
					if minutosCronometro = 59 then  -- Nueva cuenta de minutos
						minutosCronometro <= 0;    -- Nueva hora
					
						if horasCronometro = 23 then
							horasCronometro <= 0;
						else
							horasCronometro <= horasCronometro + 1;
						end if;					
							
					else                             -- Control señales
						horasCronometro   <= horasCronometro;
						minutosCronometro <= minutosCronometro + 1;						
					end if;
				else                                 -- Control señales
					minutosCronometro  <= minutosCronometro;
					segundosCronometro <= segundosCronometro + 1;
				end if;

			elsif estadoCrono = parado then       -- Crono parado
				
				horasCronometro    <= horasCronometro;
				minutosCronometro  <= minutosCronometro;
				segundosCronometro <= segundosCronometro;

			elsif estadoCrono = reinicio then     -- Crono reseteado
				
				horasCronometro    <= 0;
				minutosCronometro  <= 0;
				segundosCronometro <= 0;

			else                                   -- Otro caso
				horasCronometro    <= horasCronometro;
				minutosCronometro  <= minutosCronometro;
				segundosCronometro <= segundosCronometro;
			end if;
		end if;
			
	end process;
	
	secAlarma : process(clk, rst, modoHora, b1, b2)
	begin
		if(rst = '1') then
		
			horaAlarma <= 0;
			minutoAlarma <= 0;
			segundoAlarma <= 0;
			
			amAlarm <= '1';
			sigAlarm <= '0';
			
		elsif(clk'event and clk = '1') then
			
			-- Comprobar si salta la alarma.
			if estadoAlarma = alarmOn then
				if horaActual = horaAlarma and minutosActuales = minutoAlarma then
					sigAlarm <= '1';
				else
					sigAlarm <= '0';
				end if;
			else
				sigAlarm <= '0';
			end if;
			
			-- Si se cambia el modo de la hora (12h, o 24h) se tiene que
			-- cambiar tambien el formato de la alarma.
			
			if modoHoraAnterior /= modoHora then -- Si se ha cambiado el formato
				
				if modoHora = m12 then           -- Pasar a formato 12h
					
					if horaAlarma > 12 then      -- Si son más de las 12 del mediodia
						horaAlarma <= horaAlarma - 12;
					elsif horaAlarma = 0 then    -- Si son las 12 de la noche   
						horaAlarma <= 12;
					else                         -- Otro caso
						horaAlarma <= horaAlarma;
					end if;
					
				else                               -- Pasar al formato 24h
					
					if amAlarm = '0' then          -- Si estamos después del mediodía
						if horaAlarma /= 12 then
							horaAlarma <= horaAlarma + 12;
						else
							horaAlarma <= horaAlarma;
						end if;
					else
						if horaAlarma = 12 then -- Si son las 12 de la madrugada
							horaAlarma <= 0;
						else
							horaAlarma <= horaAlarma;
						end if;
					end if;			
				end if;
			
			elsif b1 = '1' and b2 = '1' and estado = confAlarma then
			
				-- Encender/Apagar la alarma
				if estadoAlarma = alarmOff then
					estadoAlarma <= alarmOn;
				else
					estadoAlarma <= alarmOff;
				end if;

			elsif b1 = '1' and b2 /= '1' and estado = confAlarma then
				
				-- Incrementar horas, depende si estamos en modo 24h o 12h
				-- Hay que controlar el am de la propia alarma tambien
				if modoHora = m24 then   -- Modo 24
					
					if horaAlarma = 23 then -- Madrugada
						horaAlarma <= 0;
						amAlarm    <= '1';
					else
						horaAlarma <= horaAlarma + 1;
						
						if horaAlarma = 11 then  -- Tarde
							amAlarm <= '0';
						else
							amAlarm <= amAlarm;
						end if;	
					end if;
					
				elsif modoHora = m12 then -- Modo 12
				
					if horaAlarma = 12 then
						horaAlarma <= 1;
					else
						horaAlarma <= horaAlarma + 1;
							
						if horaAlarma = 11 then    -- 12 del mediodia o noche
							if amAlarm = '0' then
								amAlarm <= '1';    -- Madrugada 
							else
								amAlarm <= '0';    -- Tarde
							end if;
						else
							amAlarm <= amAlarm;
						end if;
					end if;				
				else
					horaAlarma <= horaAlarma;
					amAlarm    <= amAlarm;
				end if;

			elsif b2 = '1' and b1 /= '1' and estado = confAlarma then
				
				-- Incrementar minutos
				minutoAlarma <= minutoAlarma + 1;
			
				if minutoAlarma = 59 then
					minutoAlarma <= 0;
				end if;
				
			else
				horaAlarma    <= horaAlarma;
				minutoAlarma  <= minutoAlarma;
				segundoAlarma <= segundoAlarma;
			end if;
		end if;
		
	end process;
		
	-- Hardware encargado de controlar las entradas y el estado del reloj
	combEntradas : process(b1, b2, mode, estado)
	begin
		estadoSiguiente <= estado;
		
		case estado is
		when verHora => -- Modo ver hora
				
			if b1 = '1' and b2 /= '1' then              -- Si se pulsa b1			
				
				if modoHora = m24 then    -- Cambiamos el modo de la hora
					modoHora <= m12;
				else
					modoHora <= m24;
				end if;
	
			elsif mode = '1' then             -- pulsar el boton modo
				estadoSiguiente <= cronometro;
			elsif b1 = '1' and b2 = '1' then  -- b1 y b2 a la vez
				estadoSiguiente <= confHora;
			else                              -- Si se pulsan otros
				estadoSiguiente <= estado;
			end if;
			
		when cronometro => -- Modo Cronometro

			if b1 = '1' then
			    estadoCrono <= reinicio;			
			elsif b2 = '1' then
				
				if estadoCrono = parado then 
					estadoCrono <= enMarcha; -- Encender crono
				elsif estadoCrono = enMarcha then
					estadoCrono <= parado;   -- Pararlo
				elsif estadoCrono = reinicio then
					estadoCrono <= enMarcha; -- Encender crono
				else
					estadoCrono <= estadoCrono;
				end if;

			elsif mode = '1' then
				estadoCrono     <= estadoCrono;
				estadoSiguiente <= confAlarma;
			else
				estadoCrono     <= estadoCrono;
			end if;
		
		when confAlarma => -- Modo alarma.
		
			if mode = '1' then
				estadoSiguiente <= verHora;
			else
				estadoSiguiente <= estado;
			end if;
			
		when confHora => -- Modo configuracion de hora
			
			if b1 = '1' and b2 = '1' then
				estadoSiguiente <= verHora;
			else
				estadoSiguiente <= estado;
			end if;
			
		when others =>
			
			estadoSiguiente <= estado;
			
		end case;
					
	end process;
	
	combRefrescarDisplay : process(segundosActuales, estado)
	begin
		case estado is
		when verHora => -- Visualizacion de la hora actual
			
			horas    <= conv_std_logic_vector(horaActual, 5);
			minutos  <= conv_std_logic_vector(minutosActuales, 6);
			segundos <= conv_std_logic_vector(segundosActuales, 6);
			
			modo <= "00";
			
		when cronometro => -- Visualizacion del cronometro

			horas    <= conv_std_logic_vector(horasCronometro, 5);
			minutos  <= conv_std_logic_vector(minutosCronometro, 6);
			segundos <= conv_std_logic_vector(segundosCronometro, 6);
			
			modo <= "01";
		
		when confAlarma => -- Visualizar la hora de la alarma

			horas    <= conv_std_logic_vector(horaAlarma, 5);
			minutos  <= conv_std_logic_vector(minutoAlarma, 6);
			segundos <= conv_std_logic_vector(segundoAlarma, 6);
			
			modo <= "10";
		
		when confHora => -- Configurar la hora

			horas    <= conv_std_logic_vector(horaActual, 5);
			minutos  <= conv_std_logic_vector(minutosActuales, 6);
			segundos <= conv_std_logic_vector(segundosActuales, 6);
			
			modo <= "11";
		
		when others => -- Por defecto se muestra la hora
		
			horas    <= conv_std_logic_vector(horaActual, 5);
			minutos  <= conv_std_logic_vector(minutosActuales, 6);
			segundos <= conv_std_logic_vector(segundosActuales, 6);
			
			modo <= "00";
		
		end case;
	end process;
	
end archReloj;
