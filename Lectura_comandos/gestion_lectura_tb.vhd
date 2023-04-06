-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulación no tiene)
-- **********************************************************************
ENTITY test_gestor_lectura IS
END    test_gestor_lectura;

-- **********************************************************************
-- ARQUITECTURA   (descripción de los estímulos)
-- **********************************************************************
ARCHITECTURE test_gestor_lectura_arq OF test_gestor_lectura IS
    --Declaración de componentes
    COMPONENT gestor_lectura
    port (
        -- ENTRADAS --
	FIFO_EMPTY: in std_logic;
	FIFO_WORD_RD: in std_logic_vector(4 downto 0);
	RESET: in std_logic;
	CLK: in std_logic;
	FINISHED: in std_logic;
        -- SALIDAS
        READ_FIFO: out std_logic;
	SENTIDO: out std_logic;
	CICLOS: out std_logic_vector (3 downto 0);
	START: out std_logic
    );
    END COMPONENT;

    -- Entradas
    SIGNAL FIFO_EMPTY_test	: std_logic;
    SIGNAL FIFO_WORD_RD_test	: std_logic_vector(4 downto 0);
    SIGNAL RESET_test 		: std_logic;
    SIGNAL CLK_test		: std_logic;
    SIGNAL FINISHED_test	: std_logic;
    
    -- Salida
    SIGNAL READ_FIFO_test: std_logic;
    SIGNAL SENTIDO_test: std_logic;
    SIGNAL CICLOS_test: std_logic_vector (3 downto 0);
    SIGNAL START_test: std_logic;
    -- Internas
    SIGNAL FIN_test:  std_logic := '0' ;       -- Indica fin de simulación. Se pone a '1' al final de la simulacion. 
    					       -- Se utiliza para bloquear el reloj y apreciar mejor el final de la simulación.				       
    
    constant ciclo : time := 10 ns;  -- 100Mhz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las señales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: gestor_lectura PORT MAP(
			FIFO_EMPTY	=> FIFO_EMPTY_test,
			FIFO_WORD_RD	=> FIFO_WORD_RD_test,
			RESET		=> RESET_test,
			CLK 		=> CLK_test,
			FINISHED	=> FINISHED_test,
 		        READ_FIFO	=> READ_FIFO_test,
			SENTIDO		=> SENTIDO_test,
			CICLOS		=> CICLOS_test,
			START		=> START_test              
                     );

    GenCLK: process
    begin
        if (FIN_test='1') THEN
            CLK_test<= '0';         WAIT;     -- Bloquea el reloj
        ELSE
            CLK_test<= '1';     wait for ciclo/2;
            CLK_test<= '0';     wait for ciclo/2;
            
        END IF;
    end process GenCLK;

    GenReset: process
    begin
        RESET_test<= '1';     wait for ciclo;     -- Nos situamos en el flanco de bajada del reloj
        RESET_test<= '0';     wait;
    end process GenReset;

    tb: PROCESS
    BEGIN
    	--Inicialización
	FIFO_EMPTY_test <= '1';
	FIFO_WORD_RD_test <= "00110";
	FINISHED_test <= '0';
	
	wait for ciclo*7;
	
	FINISHED_test <= '1';
	
	
	wait for ciclo;
	
	FINISHED_test <= '0';
    		
	
	wait for ciclo;
	FIFO_WORD_RD_test <= "11110";
	
	wait for ciclo*7;
	
	FINISHED_test <= '1';
	
	
	wait for ciclo;
	
	FINISHED_test <= '0';
	wait;
	
    end process tb;
END test_gestor_lectura_arq;



















