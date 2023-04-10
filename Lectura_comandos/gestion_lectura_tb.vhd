-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulaci?n no tiene)
-- **********************************************************************
ENTITY test_gestor_lectura IS
END    test_gestor_lectura;

-- **********************************************************************
-- ARQUITECTURA   (descripci?n de los est?mulos)
-- **********************************************************************
ARCHITECTURE test_gestor_lectura_arq OF test_gestor_lectura IS
    --Declaraci?n de componentes
    COMPONENT gestor_lectura
        PORT (
            -- ENTRADAS --
            FIFO_EMPTY  : in std_logic;
            FIFO_WORD_RD: in std_logic_vector(4 downto 0);
            RESET       : in std_logic;
            CLK         : in std_logic;
            FINISHED    : in std_logic;
            -- SALIDAS
            READ_FIFO   : out std_logic;
            SENTIDO     : out std_logic;
            CICLOS      : out std_logic_vector (3 downto 0);
            START       : out std_logic
        );
    END COMPONENT;

    -- Entradas
    SIGNAL FIFO_EMPTY_test	: std_logic;
    SIGNAL FIFO_WORD_RD_test: std_logic_vector(4 downto 0);
    SIGNAL RESET_test 		: std_logic;
    SIGNAL CLK_test		    : std_logic;
    SIGNAL FINISHED_test	: std_logic;
    
    -- Salida
    SIGNAL READ_FIFO_test   : std_logic;
    SIGNAL SENTIDO_test     : std_logic;
    SIGNAL CICLOS_test      : std_logic_vector (3 downto 0);
    SIGNAL START_test       : std_logic;

    -- Internas
    CONSTANT ciclo : time := 10 ns;  -- 100Mhz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las se?ales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: gestor_lectura PORT MAP(
        FIFO_EMPTY  => FIFO_EMPTY_test,
        FIFO_WORD_RD=> FIFO_WORD_RD_test,
        RESET		=> RESET_test,
        CLK 		=> CLK_test,
        FINISHED	=> FINISHED_test,
        READ_FIFO	=> READ_FIFO_test,
        SENTIDO		=> SENTIDO_test,
        CICLOS		=> CICLOS_test,
        START		=> START_test              
    );

    GenCLK: PROCESS
    BEGIN
        CLK_test<= '1';     WAIT FOR ciclo/2;
        CLK_test<= '0';     WAIT FOR ciclo/2;
    END PROCESS GenCLK;

    GenReset: PROCESS
    BEGIN
        RESET_test <= '1';     WAIT FOR ciclo;     -- Nos situamos en el flanco de subida del reloj
        RESET_test <= '0';     WAIT;
    END PROCESS GenReset;

    tb: PROCESS
    BEGIN
    	--Inicializaci?n
        FIFO_EMPTY_test <= '1';
        FIFO_WORD_RD_test <= "00110";
        FINISHED_test <= '0';
        
        WAIT FOR ciclo*8;
        
        FINISHED_test <= '1';
        
        
        WAIT FOR ciclo;
        
        FINISHED_test <= '0';
                
        
        WAIT FOR ciclo;
        FIFO_WORD_RD_test <= "11110";
        
        WAIT FOR ciclo*15;
        
        FINISHED_test <= '1';
        
        
        WAIT FOR ciclo;
        
        FINISHED_test <= '0';
        WAIT;
	
    END PROCESS tb;
END test_gestor_lectura_arq;



















