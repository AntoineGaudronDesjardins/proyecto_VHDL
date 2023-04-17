library ieee;
use ieee.std_logic_1164.all;

entity gestor_lectura is
    generic (
        WORD_SIZE   : integer := 5;   -- MOD (D1,5) +3
        CICLOS_SIZE : integer := 4    -- MOD (D1,5) +2
    );
    port (
        -- ENTRADAS --
        FIFO_EMPTY   : in std_logic;
        FIFO_WORD_RD : in std_logic_vector(WORD_SIZE-1 downto 0);
        RESET        : in std_logic;
        CLK          : in std_logic;
        FINISHED     : in std_logic;
        -- SALIDAS
        READ_FIFO    : out std_logic;
        SENTIDO      : out std_logic;
        CICLOS       : out std_logic_vector (CICLOS_SIZE-1 downto 0);
        START        : out std_logic
    );
end entity;

architecture arch_gestor_lectura of gestor_lectura is

    -- CODIGO DEL ALUMNO --
    type ESTADOS is (idle, reading, wait_for_motor, start_motor);
    signal actual, futuro : ESTADOS;
     
begin

    -- PROCESO DE SINCRONIZACION
    process (CLK, RESET)
    begin
        -- RESET ASINCRONO A NIVEL ALTO
        if (RESET = '1') then
            actual <= idle;
        elsif (rising_edge(CLK)) then
            actual <= futuro;
        end if;
    end process;
    
    -- PROCESO COMBINACIONAL
    process (actual, FIFO_EMPTY, FINISHED, FIFO_WORD_RD)
    begin
        case actual is

            when idle =>
                READ_FIFO <= '0';
                SENTIDO <= '0';
                START <= '0';
                if (FINISHED = '0' and FIFO_EMPTY = '0') then
                    futuro <= reading;
                end if;
            
            when reading =>
                READ_FIFO <= '1';
                futuro <= start_motor;
            
            when start_motor =>
                READ_FIFO <= '0';
                START <= '1';
                SENTIDO <= FIFO_WORD_RD(WORD_SIZE-1);
                CICLOS <= FIFO_WORD_RD(WORD_SIZE-2 downto 0);
                futuro <= wait_for_motor;
            
            when wait_for_motor =>
                START <= '0';
                if (FINISHED = '1') then
                    futuro <= idle;
                end if;
            
        end case;
    end process;
    
end architecture;
