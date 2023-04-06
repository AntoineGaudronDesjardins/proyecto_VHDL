library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sistema is
    generic (
        WORD_SIZE	: integer := 5;	-- mod(D1,5) + 3
        FIFO_MAX	: integer := 6;	-- D0 + 4
        CICLOS_SIZE	: integer := 4;	-- mod(D1,5) + 2
        CICLOS_FILTER	: integer := 400000;	-- mod(D3,5) * 10 + 10 -- CAMBIAR A 40.000.000
        CICLOS_BUTTON	: std_logic_vector(3 downto 0) := "0010"; -- D7 + 5 en binario -- CAMBIAR A "1001"
       	N_MAX 		: integer := 50000 -- CAMBIAR A 50.000.000
    );
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        BUTTON_1 : in std_logic;
        BUTTON_2 : in std_logic;
        BUTTON_RESET : in std_logic; -- Este es el botón de reset

        -- SALIDAS
        MOTOR_OUT: out std_logic_vector(3 downto 0)
    );
end entity;

architecture arch_sistema of sistema is

    -- CODIGO DEL ALUMNO --
    
	-- Variables Motor Stepper
	TYPE estados_motor IS (reposo, orange, orangeyellow, yellow, yellowpink, pink, pinkblue, blue, blueorange, bluefinal, orangefinal, final1);
	SIGNAL motor_s, motor_c 	: estados_motor;
	SIGNAL contador_motor 		: INTEGER := 0;
    
	-- Variables Gestion Lectura
	TYPE estados_lectura IS (idle, reading, wait_for_motor, start_motor);
	SIGNAL lectura_s, lectura_c : estados_lectura;
	
	-- Variable Divisor de Frecuencia
	SIGNAL contador_divisor 	: integer range 0 to N_MAX - 1 := 0;
	SIGNAL senal 			: std_logic := '1';
    
	-- Variables Gestion Escritura
	TYPE estados_escritura IS (reposo, escritura1, escritura2, lleno);
	SIGNAL escritura_s, escritura_c : estados_escritura;
	
	-- Variables Antirebotes
	TYPE estados_antirebotes IS (inactivo, activo1, activo2);
	SIGNAL antirebotes_s, antirebotes_c : estados_antirebotes;
     	SIGNAL ciclos_antirebotes 	: integer := CICLOS_FILTER;
	SIGNAL contador_antirebotes1 	: integer := 0;
	SIGNAL contador_antirebotes2 	: integer := 0;
	
	-- Variables FIFO Circular
	TYPE   FIFO_DATA_TYPE is array(0 to FIFO_MAX-1) of std_logic_vector(WORD_SIZE-1 downto 0);
	SIGNAL FIFO_DATA		: FIFO_DATA_TYPE := (others => (others => '0'));
	SIGNAL WRITE_POINTER		: integer := 0;
	SIGNAL READ_POINTER		: integer := 0;
	SIGNAL FIFO_COUNT		: integer := 0;
     
	-- Variables Internas
	--SIGNAL BUTTON_OUT		: std_logic;
	SIGNAL BUTTON_IN_1		: std_logic				:= '0';
	SIGNAL BUTTON_IN_2		: std_logic				:= '0';
	SIGNAL CICLOS	 		: std_logic_vector(CICLOS_SIZE-1 downto 0);
	SIGNAL CLK_SLOW			: std_logic;
	SIGNAL FIFO_EMPTY 		: std_logic;				-- Vacio = 0 / Con valores = 1
	SIGNAL FIFO_FULL 		: std_logic;
     	SIGNAL FIFO_WORD_RD		: std_logic_vector(4 downto 0);
     	SIGNAL FINISHED 		: std_logic;
     	SIGNAL LED 			: std_logic;
     	SIGNAL READ_FIFO 		: std_logic;
     	SIGNAL SENTIDO 			: std_logic;
     	SIGNAL START	 		: std_logic;
     	SIGNAL WRITE_FIFO 		: std_logic;
	SIGNAL FIFO_WORD_WR 		: std_logic_vector(4 downto 0);
     
BEGIN

	PROCESS (CLK,BUTTON_RESET)
	BEGIN
        	IF (BUTTON_RESET='1') THEN                 -- Reset activo a nviel alto
			lectura_s		<= idle;
			escritura_s		<= reposo;          
		ELSIF (rising_edge(CLK)) THEN
			lectura_s <= lectura_c;
			escritura_s  <= escritura_c;
			antirebotes_s  <= antirebotes_c;
			IF (antirebotes_s = inactivo) THEN
				IF(BUTTON_1 = '1') THEN
					contador_antirebotes1 <= contador_antirebotes1 + 1;
					IF (contador_antirebotes1 = ciclos_antirebotes) THEN
						contador_antirebotes1 <= 0;	
					END IF;
				ELSE
					contador_antirebotes1 <= 0;	
				END IF;
				IF(BUTTON_2 = '1') THEN
					contador_antirebotes2 <= contador_antirebotes2 + 1;
					IF (contador_antirebotes2 = ciclos_antirebotes) THEN
						contador_antirebotes2 <= 0;	
					END IF;
				ELSE
					contador_antirebotes2 <= 0;	
				END IF;	
			END IF;
		END IF;
	END PROCESS;
    
	PROCESS (CLK_SLOW,BUTTON_RESET, motor_s, lectura_s)
	BEGIN
		IF (BUTTON_RESET='1') THEN                 -- Reset activo a nviel alto
        		motor_s			<= reposo;
        		contador_motor		<= 0;
        	ELSIF (rising_edge(CLK_SLOW)) THEN  
			motor_s  <= motor_c;
			IF (motor_s = blueorange) THEN
				contador_motor <= contador_motor + 1;
			ELSIF (motor_s = reposo) THEN
				contador_motor <= 0;	
			END IF;
		END IF;
			
	END PROCESS;
	
	-- Proceso Motor Stepper
    
	PROCESS (motor_s, SENTIDO, START, contador_motor)
	BEGIN
		CASE motor_s IS
			WHEN reposo =>
				MOTOR_OUT <= "0000";
				FINISHED <= '0';
				IF (START='1') THEN
					IF(SENTIDO = '1') THEN
						motor_c <= orange;
					ELSE
						motor_c <= blue;
					END IF;
				END IF;	
			WHEN orange =>
				MOTOR_OUT <= "1000";
				IF (SENTIDO = '1') THEN
					motor_c <= yellow;
				ELSE
					IF (contador_motor = CICLOS-1) THEN
						motor_c <= orangefinal;
					ELSE
						motor_c <= blueorange;
					END IF;
				END IF;	
			WHEN orangeyellow =>
				MOTOR_OUT <= "1100";
				IF (SENTIDO = '1') THEN
					motor_c <= yellow;
				ELSE
					motor_c <= orange;
				END IF;		
			WHEN yellow =>		
				MOTOR_OUT <= "0100";
				IF (SENTIDO = '1') THEN
					motor_c <= yellowpink;
				ELSE
					motor_c <= orangeyellow;
				END IF;	
			WHEN yellowpink =>
				MOTOR_OUT <= "0110";
				IF (SENTIDO = '1') THEN
					motor_c <= pink;
				ELSE
					motor_c <= yellow;
				END IF;					
			WHEN pink =>		
				MOTOR_OUT <= "0010";
				IF (SENTIDO = '1') THEN
					motor_c <= pinkblue;
				ELSE
					motor_c <= yellowpink;
				END IF;
			WHEN pinkblue =>
				MOTOR_OUT <= "0011";
				IF (SENTIDO = '1') THEN
					motor_c <= blue;
				ELSE
					motor_c <= pink;
				END IF;
			WHEN blue =>
				MOTOR_OUT <= "0001";
				IF (SENTIDO = '1') THEN
					IF (contador_motor = CICLOS-1) THEN
						motor_c <= bluefinal;
					ELSE	
						motor_c <= blueorange;
					END IF;
				ELSE
					motor_c <= pinkblue;
				END IF;
			WHEN blueorange =>
				MOTOR_OUT <= "1001";
				IF (SENTIDO = '1') THEN
					motor_c <= orange;
				ELSE
					motor_c <= blue;
				END IF;
			WHEN bluefinal =>
				MOTOR_OUT <= "0001";
				motor_c <= final1;
			WHEN orangefinal =>
				MOTOR_OUT <= "1000";
				motor_c <= final1;
			WHEN final1 =>
				MOTOR_OUT <= "0000";
				FINISHED <= '1';
				motor_c <= reposo;
                	WHEN OTHERS =>
                		MOTOR_OUT <= "0000"; 
		END CASE;		
	END PROCESS;
    
	-- Proceso Gestion Lectura
    
	PROCESS (lectura_s, FIFO_EMPTY, FINISHED)
	BEGIN
		CASE lectura_s IS
			WHEN idle =>
    				READ_FIFO <= '0';
    				SENTIDO <= '0';
    				START <= '0';
    				CICLOS <= "0000";
    		   		IF (FIFO_EMPTY = '1') THEN
    		   			lectura_c <= reading;
    		   		END IF;
    			WHEN reading =>
    				READ_FIFO <= '1';
    				lectura_c <= wait_for_motor;
    			WHEN wait_for_motor =>
    				READ_FIFO <= '0';
    				START <= '1';
    				SENTIDO <= FIFO_WORD_RD(4);
    				CICLOS <= FIFO_WORD_RD(3 DOWNTO 0);
    				lectura_c <= start_motor;
    			WHEN start_motor =>
    				START <= '0';
    				IF (FINISHED = '1') THEN
    			     		IF (FIFO_EMPTY = '1') THEN
    		 	  			lectura_c <= reading;
    		   		ELSE 
    		 	  			lectura_c <= idle;
    		   			END IF;
    				END IF;	
		END CASE;
	END PROCESS;
    
	-- Procesos Divisor de Frecuencia
	
	PROCESS (CLK,BUTTON_RESET)
	BEGIN
		IF (BUTTON_RESET='1') THEN                 -- Reset activo a nviel alto
			contador_divisor <= 0;
			CLK_SLOW <= '0';
		ELSIF (rising_edge(CLK)) THEN  
			contador_divisor <= contador_divisor + 1;
			IF (contador_divisor = N_MAX - 1) THEN
				senal <= NOT senal;
            			CLK_SLOW <= senal;
            			contador_divisor <= 0;
            		END IF;
       		END IF;
	END PROCESS; 
	
	-- Proceso FIFO Circular
	
	process(BUTTON_RESET, CLK)
	begin
		
        if (BUTTON_RESET='1') then

            FIFO_DATA		<= (others => (others => '0'));
            WRITE_POINTER	<= 0;
            READ_POINTER	<= 0;
            FIFO_COUNT		<= 0;            
            
            FIFO_EMPTY		<= '0';
            FIFO_FULL 		<= '0';

        elsif (rising_edge(CLK)) then
			    
            if (WRITE_FIFO='1') then
                -- write --
                FIFO_DATA(WRITE_POINTER) <= FIFO_WORD_WR;
                
                -- actualize COUNT and POINTER --
                FIFO_COUNT <= FIFO_COUNT + 1;
                if (WRITE_POINTER = FIFO_MAX-1) then
                    WRITE_POINTER <= 0;
                else
                    WRITE_POINTER <= WRITE_POINTER + 1;
                end if;
                
                -- update state --
                FIFO_EMPTY <= '1';
                if (FIFO_COUNT + 1 = FIFO_MAX) then
                    FIFO_FULL <= '1';
                end if;
            end if;
        
            if (READ_FIFO='1') then
                -- read --
                FIFO_WORD_RD <= FIFO_DATA(READ_POINTER);
                
                -- actualize COUNT and POINTER --
                FIFO_COUNT <= FIFO_COUNT - 1;
                if (READ_POINTER = FIFO_MAX-1) then
                    READ_POINTER <= 0;
                else
                    READ_POINTER <= READ_POINTER + 1;
                end if;
                
                -- update state --
                FIFO_FULL <= '0';
                if (FIFO_COUNT - 1 = 0) then
                    FIFO_EMPTY <= '0';
                end if;
            end if;
        
        end if;
    
    end process;
    
    
	-- Proceso Gestion Escritura
    
	PROCESS (escritura_s, escritura_c, BUTTON_IN_1, BUTTON_IN_2, FIFO_FULL)
	BEGIN
		CASE escritura_s IS
			WHEN reposo =>
				WRITE_FIFO <= '0';
				FIFO_WORD_WR <= "00000";
				LED <= FIFO_FULL;
				IF (FIFO_FULL = '0') THEN
					IF (BUTTON_IN_1 = '1') THEN
						escritura_c <= escritura1;
					ELSIF (BUTTON_IN_2 = '1') THEN
						escritura_c <= escritura2;
					END IF;
				END IF;	
			WHEN escritura1 =>
				WRITE_FIFO <= '1';
				escritura_c <= reposo;
				IF (FIFO_FULL = '1') THEN
					escritura_c <= lleno;
				END IF;	
				FIFO_WORD_WR <= '0' & CICLOS_BUTTON;
				LED <= FIFO_FULL;
			WHEN escritura2 =>
				WRITE_FIFO <= '1';
				escritura_c <= reposo;
				IF (FIFO_FULL = '1') THEN
					escritura_c <= lleno;
				END IF;	
				FIFO_WORD_WR <= '1' & CICLOS_BUTTON;
				LED <= FIFO_FULL;
			WHEN lleno =>
				WRITE_FIFO <= '0';	
		END CASE;	                                                   			
	END PROCESS;   
    
	-- Modulo Antirebotes
 
	PROCESS (antirebotes_s,CLK)
	BEGIN
    		CASE antirebotes_s IS
    			WHEN inactivo =>
    				BUTTON_IN_1 <= '0';
    				BUTTON_IN_2 <= '0';
				IF(BUTTON_1 = '1') THEN
					IF (contador_antirebotes1 = ciclos_antirebotes) THEN
						antirebotes_c <= activo1;
					END IF;
				END IF;
				IF(BUTTON_2 = '1') THEN
					IF (contador_antirebotes2 = ciclos_antirebotes) THEN
						antirebotes_c <= activo2;
					END IF;
				END IF;	
    			WHEN activo1 =>
    				BUTTON_IN_1 <= '1';
    				antirebotes_c <= inactivo;
			WHEN activo2 =>
    				BUTTON_IN_2 <= '1';
    				antirebotes_c <= inactivo;
    		END CASE;                                                     			
    END PROCESS;    

end architecture;
    







