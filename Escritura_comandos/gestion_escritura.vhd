library ieee;
use ieee.std_logic_1164.all;

entity gestor_escritura is
    generic (
    	WORD_SIZE	: integer := 5;   -- mod(7,5)+ 3 = 5
    	WORD_FIFO	: std_logic_vector(3 downto 0) := "1001"     ----D7 +5 EN BINARIO
    );
    port (
        -- ENTRADAS --
        CLK			: in std_logic;
        RESET		: in std_logic;
        BUTTON_1	: in std_logic;
        BUTTON_2	: in std_logic;
        FIFO_FULL	: in std_logic;
        -- SALIDAS
        WRITE_FIFO	: out std_logic;
        WORD_FIFO_WR: out std_logic_vector(WORD_SIZE-1 downto 0); 
        LED			: out std_logic
    );
end entity;

architecture arch_gestor_escritura of gestor_escritura is

    -- CODIGO DEL ALUMNO --
	type ESTADOS is (reposo, escritura1, escritura2, lleno);
	signal actual, futuro : ESTADOS := reposo;

begin

	-- PROCESO DE SINCRONIZACION
    process (CLK)
    begin
        if (rising_edge(CLK)) then
            -- RESET SINCRONO A NIVEL ALTO
			if (RESET='1') then
            	actual  <= reposo;
			else
            	actual  <= futuro;
			end if;
       	end if;
    end process;
    
	-- PROCESO COMBINACIONAL
    process (actual, BUTTON_1, BUTTON_2, FIFO_FULL)
    begin
		LED <= FIFO_FULL;

		case actual is
			when reposo =>
				WRITE_FIFO <= '0';
				if (FIFO_FULL = '0') then
					if (BUTTON_1 = '1') then
						futuro <= escritura1;
					elsif (BUTTON_2 = '1') then
						futuro <= escritura2;
					end if;
				end if;
			
			when escritura1 =>
				WRITE_FIFO <= '1';
				futuro <= reposo;
				WORD_FIFO_WR <= '0' & WORD_FIFO;
			
			when escritura2 =>
				WRITE_FIFO <= '1';
				futuro <= reposo;
				WORD_FIFO_WR <= '1' & WORD_FIFO;
			
			when others =>
				WRITE_FIFO <= '0';
				WORD_FIFO_WR <= (others => '0');
				futuro <= reposo;				
			
		end case;                                 			
    end process;

end architecture;
