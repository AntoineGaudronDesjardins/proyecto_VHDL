library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity motor_stepper is
    port (
        -- ENTRADAS --
        CLK_SLOW : in std_logic;
        RESET : in std_logic;
        SENTIDO: in std_logic;
        CICLOS: in std_logic_vector(3 downto 0); -- mod(7,5)+2 = 4
        START: in std_logic;
        -- SALIDAS
        MOTOR_OUT: out std_logic_vector(3 downto 0);
        FINISHED: out std_logic
    );
end entity;

architecture arch_motor_stepper of motor_stepper is

    -- CODIGO DEL ALUMNO --
     TYPE ESTADOS IS (reposo, orange, orangeyellow, yellow, yellowpink, pink, pinkblue, blue, blueorange, bluefinal, orangefinal, final1);
     SIGNAL estado_s, estado_c : ESTADOS := reposo;
     SIGNAL contador : INTEGER := 0;
     
BEGIN
    

	PROCESS (CLK_SLOW,RESET, estado_s, contador)
	BEGIN
		IF (RESET='1') THEN                 -- Reset activo a nviel alto
        	    estado_s  <= reposo;
        	    contador  <= 0;
        	ELSIF (rising_edge(CLK_SLOW)) THEN  
			estado_s  <= estado_c;
			IF (estado_s = blueorange) THEN
				contador <= contador + 1;
			ELSIF (estado_s = reposo) THEN
				contador <= 0;	
			END IF;
		END IF;
	END PROCESS;
    
	PROCESS (estado_s, SENTIDO, START, contador)
	BEGIN
		CASE estado_s IS
			WHEN reposo =>
				MOTOR_OUT <= "0000";
				FINISHED <= '0';
				IF (START='1') THEN
					IF(SENTIDO = '1') THEN
						estado_c <= orange;
					ELSE
						estado_c <= blue;
					END IF;
				END IF;	
			WHEN orange =>
				MOTOR_OUT <= "1000";
				IF (SENTIDO = '1') THEN
					estado_c <= yellow;
				ELSE
					IF (contador = CICLOS-1) THEN
						estado_c <= orangefinal;
					ELSE
						estado_c <= blueorange;
					END IF;
				END IF;	
			WHEN orangeyellow =>
				MOTOR_OUT <= "1100";
				IF (SENTIDO = '1') THEN
					estado_c <= yellow;
				ELSE
					estado_c <= orange;
				END IF;		
			WHEN yellow =>		
				MOTOR_OUT <= "0100";
				IF (SENTIDO = '1') THEN
					estado_c <= yellowpink;
				ELSE
					estado_c <= orangeyellow;
				END IF;	
			WHEN yellowpink =>
				MOTOR_OUT <= "0110";
				IF (SENTIDO = '1') THEN
					estado_c <= pink;
				ELSE
					estado_c <= yellow;
				END IF;					
			WHEN pink =>		
				MOTOR_OUT <= "0010";
				IF (SENTIDO = '1') THEN
					estado_c <= pinkblue;
				ELSE
					estado_c <= yellowpink;
				END IF;
			WHEN pinkblue =>
				MOTOR_OUT <= "0011";
				IF (SENTIDO = '1') THEN
					estado_c <= blue;
				ELSE
					estado_c <= pink;
				END IF;
			WHEN blue =>
				MOTOR_OUT <= "0001";
				IF (SENTIDO = '1') THEN
					IF (contador = CICLOS-1) THEN
						estado_c <= bluefinal;
					ELSE	
						estado_c <= blueorange;
					END IF;
				ELSE
					estado_c <= pinkblue;
				END IF;
			WHEN blueorange =>
				MOTOR_OUT <= "1001";
				IF (SENTIDO = '1') THEN
					estado_c <= orange;
				ELSE
					estado_c <= blue;
				END IF;
			WHEN bluefinal =>
				MOTOR_OUT <= "0001";
				estado_c <= final1;
			WHEN orangefinal =>
				MOTOR_OUT <= "1000";
				estado_c <= final1;
			WHEN final1 =>
				MOTOR_OUT <= "0000";
				FINISHED <= '1';
				estado_c <= reposo;
                	WHEN OTHERS =>
                		MOTOR_OUT <= "0000"; 
		END CASE;		
	END PROCESS;
	
   
end architecture;
    





