library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
    generic (
        WORD_SIZE	: integer := 4; -- D1 = 6
        FIFO_MAX	: integer := 8
    );
    port (
        -- ENTRADAS --
        CLK		: in std_logic;
        RESET		: in std_logic;
        WRITE_FIFO	: in std_logic;
        READ_FIFO	: in std_logic;
        FIFO_WORD_WR	: in std_logic_vector(WORD_SIZE-1 downto 0);
        -- SALIDAS
        FIFO_WORD_RD	: out std_logic_vector(WORD_SIZE-1 downto 0);
        FIFO_EMPTY	: out std_logic;
        FIFO_FULL	: out std_logic
    );
    
end entity;

architecture arch_fifo of fifo is

    -- CODIGO DEL ALUMNO --
    type FIFO_DATA_TYPE is array(0 to FIFO_MAX-1) of std_logic_vector(WORD_SIZE-1 downto 0);
    signal FIFO_DATA		: FIFO_DATA_TYPE := (others => (others => '0'));
    signal WRITE_POINTER	: integer := 0;
    signal READ_POINTER		: integer := 0;
    signal FIFO_COUNT		: integer := 0;

begin

    process(RESET, CLK)
    begin
		
        if (RESET='1') then

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

end architecture;
    


