library ieee;
use ieee.std_logic_1164.all;

entity gestor_escritura is
    generic (
    	WORD_SIZE :integer := 5;   -- mod(7,5)+ 3 = 5
    	CICLOS_BUTTON : std_logic_vector(3 downto 0)  := "1001"     ----D7 +5 EN BINARIO
    );
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        RESET : in std_logic;
        BUTTON_1 : in std_logic;
        BUTTON_2 : in std_logic;
        FIFO_FULL : in std_logic;
        -- SALIDAS
        WRITE_FIFO: out std_logic;
        WORD_FIFO_WR: out std_logic_vector(WORD_SIZE-1 downto 0); 
        LED: out std_logic
    );
end entity;

architecture arch_gestor_escritura of gestor_escritura is

    -- CODIGO DEL ALUMNO --
     TYPE ESTADOS IS (reposo, escritura1, escritura2, lleno);
     SIGNAL estado_s, estado_c : ESTADOS := reposo;
begin


    PROCESS (CLK,RESET)
    BEGIN
        IF (RESET='1') THEN                 -- Reset activo a nviel alto
            estado_s  <= reposo;
        ELSIF (rising_edge(CLK)) THEN  
            estado_s  <= estado_c;
       END IF;
    END PROCESS;
    
 
    PROCESS (estado_s, estado_c, RESET, BUTTON_1, BUTTON_2, FIFO_FULL)
    BEGIN
	case estado_s is
		when reposo =>
			WRITE_FIFO <= '0';
			WORD_FIFO_WR <= "00000";
			LED <= FIFO_FULL;
			if (FIFO_FULL = '0') then
				if (BUTTON_1 = '1') then
					estado_c <= escritura1;
				elsif (BUTTON_2 = '1') then
					estado_c <= escritura2;
				end if;
			end if;	
		when escritura1 =>
			WRITE_FIFO <= '1';
			estado_c <= reposo;
			if (FIFO_FULL = '1') then
				estado_c <= lleno;
			end if;
			WORD_FIFO_WR <= '0' & CICLOS_BUTTON;
			LED <= FIFO_FULL;
		when escritura2 =>
			WRITE_FIFO <= '1';
			estado_c <= reposo;
			if (FIFO_FULL = '1') then
				estado_c <= lleno;
			end if;
			WORD_FIFO_WR <= '1' & CICLOS_BUTTON;
			LED <= FIFO_FULL;
		when lleno =>
			WRITE_FIFO <= '0';	
	end case;	
	                                                          			
    END PROCESS;
    
        
end architecture;
    




