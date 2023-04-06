library ieee;
use ieee.std_logic_1164.all;

entity gestor_lectura is
    generic (
    	WORD_SIZE : integer := 5;    ---MOD (D1,5) +3
    	CICLOS_SIZE : integer := 4    ---MOD (D1,5) +2
    );
    port (
        -- ENTRADAS --
	FIFO_EMPTY: in std_logic;
	FIFO_WORD_RD: in std_logic_vector(WORD_SIZE-1 downto 0);
	RESET: in std_logic;
	CLK: in std_logic;
	FINISHED: in std_logic;
        -- SALIDAS
        READ_FIFO: out std_logic;
	SENTIDO: out std_logic;
	CICLOS: out std_logic_vector (CICLOS_SIZE-1 downto 0);
	START: out std_logic
    );
end entity;

architecture arch_gestor_lectura of gestor_lectura is

    -- CODIGO DEL ALUMNO --
    TYPE ESTADOS IS (idle, reading, wait_for_motor, start_motor);
    SIGNAL estado_s, estado_c : ESTADOS;
     
    begin
    PROCESS (CLK,RESET)
    BEGIN
        IF (RESET='1') THEN                 -- Reset activo a nviel alto
            estado_s  <= idle;
        ELSIF (rising_edge(CLK)) THEN  
            estado_s  <= estado_c;
       END IF;
    END PROCESS;
    
    PROCESS (estado_s, FIFO_EMPTY, FINISHED)
    BEGIN
    	Case estado_s is
    		when idle =>
    			READ_FIFO <= '0';
    			SENTIDO <= '0';
    			START <= '0';
    			CICLOS <= "0000";
    		   IF (FIFO_EMPTY = '1') then
    		   	estado_c <= reading;
    		   end if;
    		when reading =>
    			READ_FIFO <= '1';
    			estado_c <= wait_for_motor;
    		when wait_for_motor =>
    			READ_FIFO <= '0';
    			START <= '1';
    			SENTIDO <= FIFO_WORD_RD(4);
    			CICLOS <= FIFO_WORD_RD(3 downto 0);
    			estado_c <= start_motor;
    		when start_motor =>
    			START <= '0';
    			IF (FINISHED = '1') then
    		     		IF (FIFO_EMPTY = '1') then
    		   			estado_c <= reading;
    		   		else 
    		   			estado_c <= idle;
    		   		end if;
    			end if;  	
    		end case;
    END PROCESS;
	
end architecture;
    

