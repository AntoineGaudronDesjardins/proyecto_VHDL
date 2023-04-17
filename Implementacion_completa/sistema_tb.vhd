-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulaci�n no tiene)
-- **********************************************************************
ENTITY test_sistema IS
END    test_sistema;

-- **********************************************************************
-- ARQUITECTURA   (descripci�n de los est�mulos)
-- **********************************************************************
ARCHITECTURE test_sistema_arq OF test_sistema IS
    --Declaraci�n de componentes
    COMPONENT sistema
    PORT (
        -- ENTRADAS --
        CLK          : in std_logic;
        BUTTON_1     : in std_logic;
        BUTTON_2     : in std_logic;
        BUTTON_RESET : in std_logic; -- Este es el botón de reset

        -- SALIDAS --
        MOTOR_OUT : out std_logic_vector(3 downto 0);
        LED       : out std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test          : std_logic;
    SIGNAL BUTTON_1_test     : std_logic;
    SIGNAL BUTTON_2_test     : std_logic;        
    SIGNAL BUTTON_RESET_test : std_logic;
    
    -- Salida
    SIGNAL MOTOR_OUT_test : std_logic_vector(3 downto 0);
    SIGNAL LED_test       : std_logic;

    
    -- Internas
    constant ciclo : time := 10 ns;  -- 100Mhz

BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las se�ales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: sistema PORT MAP(
        CLK          => CLK_test,
        BUTTON_1     => BUTTON_1_test,
        BUTTON_2     => BUTTON_2_test,
        BUTTON_RESET => BUTTON_RESET_test,
        MOTOR_OUT    => MOTOR_OUT_test,
        LED          => LED_test
    );

    GenCLK: process
    begin
        CLK_test<= '1';     wait for ciclo/2;
        CLK_test<= '0';     wait for ciclo/2;
    end process GenCLK;

    GenReset: process
    begin
        BUTTON_RESET_test<= '1';     wait for 5 ms;
        BUTTON_RESET_test<= '0';     wait;
    end process GenReset;

    tb: PROCESS
    BEGIN
        -- Inicializaci�n
        BUTTON_1_test <= '0';
        BUTTON_2_test <= '0';
        
        wait for 10 ms;
        
        -- Este pulso no es detectado por ser inferior al 40ms minimo del filtro antirebotes
        BUTTON_1_test <= '1'; wait for 20 ms;
        BUTTON_1_test <= '0';

        wait for 10 ms;
        
        -- Este pulso si es detectado
        BUTTON_2_test <= '1'; wait for 80 ms;
        BUTTON_2_test <= '0';
        
        wait;
    end process tb;
END test_sistema_arq;
