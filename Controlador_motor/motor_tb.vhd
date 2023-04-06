-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulación no tiene)
-- **********************************************************************
ENTITY test_motor IS
END    test_motor;

-- **********************************************************************
-- ARQUITECTURA   (descripción de los estímulos)
-- **********************************************************************
ARCHITECTURE test_motor_arq OF test_motor IS
    --Declaración de componentes
    COMPONENT motor_stepper
    	port (
        	-- ENTRADAS --
        	CLK_SLOW 	: in std_logic;
        	RESET 		: in std_logic;
        	SENTIDO		: in std_logic;
        	CICLOS		: in std_logic_vector(3 downto 0);
        	START		: in std_logic;
        	-- SALIDAS
        	MOTOR_OUT	: out std_logic_vector(3 downto 0);
        	FINISHED	: out std_logic
    	);
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_SLOW_test	: std_logic;
    SIGNAL RESET_test 		: std_logic;
    SIGNAL SENTIDO_test		: std_logic;
    SIGNAL CICLOS_test		: std_logic_vector(3 downto 0);
    SIGNAL START_test		: std_logic;
    
    -- Salida
    SIGNAL MOTOR_OUT_test  	: std_logic_vector(3 downto 0);
    SIGNAL FINISHED_test  	: std_logic;
    
    -- Internas
    SIGNAL FIN_test:  std_logic := '0' ;       -- Indica fin de simulación. Se pone a '1' al final de la simulacion. 
    					       -- Se utiliza para bloquear el reloj y apreciar mejor el final de la simulación.
    SIGNAL CLK_MOTOR_test : std_logic := '0';					       
    
    constant ciclo : time := 10 ms;  -- 100Hz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las señales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: motor_stepper PORT MAP(
                        CLK_SLOW => CLK_SLOW_test,
                        RESET    => RESET_test,
                        SENTIDO	 => SENTIDO_test,
                        CICLOS	 => CICLOS_test,
                        START	 => START_test,
                        MOTOR_OUT=> MOTOR_OUT_test,
                        FINISHED => FINISHED_test
                     );


    -- ======================================================================
    -- Proceso del reloj. Se ejecuta hasta que FIN_test='1'
    -- ======================================================================
    GenCLK: process
    begin
        if (FIN_test='1') THEN
            CLK_MOTOR_test<= '0';         WAIT;     -- Bloquea el reloj
        ELSE
            CLK_MOTOR_test<= '1';     wait for ciclo/2;
            CLK_MOTOR_test<= '0';     wait for ciclo/2;
            
        END IF;
    end process GenCLK;

    Gen2CLK: process
    begin
        if (FIN_test='1') THEN
            CLK_SLOW_test<= '0';         WAIT;     -- Bloquea el reloj
        ELSE
            CLK_SLOW_test<= '1';     wait for 25*ciclo;
            CLK_SLOW_test<= '0';     wait for 25*ciclo;
            
        END IF;
    end process Gen2CLK;
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
    	SENTIDO_test	<= '1';
    	CICLOS_test 	<= "1001"; -- 4 + 5 = 9
    	START_test	<= '0';
    	
    	wait for 50*ciclo*3;
    	
    	START_test	<= '1';
    	wait for 50*ciclo;
    	
    	START_test	<= '0';
    	wait for 50*ciclo*20;
    	
    	START_test	<= '1';   	
    	wait for 50*ciclo;
    	
    	START_test	<= '0';    	
	
	
	wait;
	
    end process tb;
END test_motor_arq;
















