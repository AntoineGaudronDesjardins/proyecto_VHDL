-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulación no tiene)
-- **********************************************************************
ENTITY test_gestor_escritura IS
END    test_gestor_escritura;

-- **********************************************************************
-- ARQUITECTURA   (descripción de los estímulos)
-- **********************************************************************
ARCHITECTURE test_gestor_escritura_arq OF test_gestor_escritura IS
    --Declaración de componentes
    COMPONENT gestor_escritura
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        RESET : in std_logic;
        BUTTON_1 : in std_logic;
        BUTTON_2 : in std_logic;
        FIFO_FULL : in std_logic;
        -- SALIDAS
        WRITE_FIFO: out std_logic;
        WORD_FIFO_WR: out std_logic_vector(5 downto 0); -- mod(7,5)+ 3 = 5
        LED: out std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test		: std_logic;
    SIGNAL RESET_test 		: std_logic;
    SIGNAL BUTTON_1_test	: std_logic;
    SIGNAL BUTTON_2_test	: std_logic;
    SIGNAL FIFO_FULL_test	: std_logic;
    
    -- Salida
    SIGNAL WRITE_FIFO_test  	: std_logic;
    SIGNAL WORD_FIFO_WR_test	: std_logic_vector(5 downto 0);
    SIGNAL LED_test		: std_logic;
    
    -- Internas
    SIGNAL FIN_test:  std_logic := '0' ;       -- Indica fin de simulación. Se pone a '1' al final de la simulacion. 
    					       -- Se utiliza para bloquear el reloj y apreciar mejor el final de la simulación.
    
    constant ciclo : time := 10 ms;  -- 100Hz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las señales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: gestor_escritura PORT MAP(
                        CLK		=> CLK_test,
                        RESET		=> RESET_test,
                        BUTTON_1	=> BUTTON_1_test,
                        BUTTON_2	=> BUTTON_2_test,
                        FIFO_FULL	=> FIFO_FULL_test,
                        WRITE_FIFO	=> WRITE_FIFO_test,
                        WORD_FIFO_WR	=> WORD_FIFO_WR_test,
                        LED	 	=> LED_test
                     );


    -- ======================================================================
    -- Proceso del reloj. Se ejecuta hasta que FIN_test='1'
    -- ======================================================================
    GenCLK: process
    begin
        if (FIN_test='1') THEN
            CLK_test<= '0';         WAIT;     -- Bloquea el reloj
        ELSE
            CLK_test<= '1';     wait for ciclo/2;
            CLK_test<= '0';     wait for ciclo/2;
            
        END IF;
    end process GenCLK;

    -- ======================================================================
    -- Proceso del reloj. Se ejecuta hasta que FIN_test='1'
    -- ======================================================================
    GenReset: process
    begin
        RESET_test<= '1';     wait for ciclo;     -- Nos situamos en el flanco de bajada del reloj
        RESET_test<= '0';     wait;
    end process GenReset;

    -- ======================================================================
    -- Proceso para el banco de pruebas para el componente de tipo "tren"
    -- ======================================================================
    tb: PROCESS
    BEGIN
    	--Inicialización	
	BUTTON_1_test <= '0';
	BUTTON_2_test <= '0';
	FIFO_FULL_test<= '1';
	
	wait for ciclo*3;
	
	BUTTON_1_test <= '1';	wait for ciclo;
	BUTTON_1_test <= '0';	wait for ciclo*5;
	
	FIFO_FULL_test<= '0';
	BUTTON_2_test <= '1';	wait for ciclo;
	BUTTON_2_test <= '0';	wait for ciclo*5;
	
	wait;
	
    end process tb;
END test_gestor_escritura_arq;


















