-- **********************************************************************
-- LIBRERIAS
-- **********************************************************************
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- **********************************************************************
-- ENTIDAD     (entradas/salidas, el fichero de simulación no tiene)
-- **********************************************************************
ENTITY test_sistema IS
END    test_sistema;

-- **********************************************************************
-- ARQUITECTURA   (descripción de los estímulos)
-- **********************************************************************
ARCHITECTURE test_sistema_arq OF test_sistema IS
    --Declaración de componentes
    COMPONENT sistema
    port (
        -- ENTRADAS --
        CLK : in std_logic;
        BUTTON_1 : in std_logic;
        BUTTON_2 : in std_logic;
        BUTTON_RESET : in std_logic; -- Este es el botÃ³n de reset

        -- SALIDAS
        MOTOR_OUT: out std_logic_vector(3 downto 0)
    );
    END COMPONENT;

    -- Entradas
    SIGNAL CLK_test		: std_logic;
    SIGNAL BUTTON_1_test	: std_logic;
    SIGNAL BUTTON_2_test	: std_logic;        
    SIGNAL BUTTON_RESET_test 	: std_logic;
    
    -- Salida
    SIGNAL MOTOR_OUT_test  	: std_logic_vector(3 downto 0);

    
    -- Internas
    SIGNAL FIN_test:  std_logic := '0' ;       -- Indica fin de simulación. Se pone a '1' al final de la simulacion. 
    					       -- Se utiliza para bloquear el reloj y apreciar mejor el final de la simulación.				       
    
    constant ciclo : time := 10 ns;  -- 100Mhz


BEGIN
    -- ///////////////////////////////////////////////////////////////////////////////
    -- Se crea el componente U1 y se conecta a las señales internas de la arquitectura
    -- ///////////////////////////////////////////////////////////////////////////////
    U1: sistema PORT MAP(
                        CLK 		=> CLK_test,
                        BUTTON_1 	=> BUTTON_1_test,
                        BUTTON_2 	=> BUTTON_2_test,
                        BUTTON_RESET	=> BUTTON_RESET_test,
                        MOTOR_OUT	=> MOTOR_OUT_test                      
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
        BUTTON_RESET_test<= '1';     wait for ciclo;     -- Nos situamos en el flanco de bajada del reloj
        BUTTON_RESET_test<= '0';     wait;
    end process GenReset;

    tb: PROCESS
    BEGIN
    	--Inicialización

    	BUTTON_1_test <= '0';
	BUTTON_2_test <= '0';
	
	wait for ciclo*20;
	
	BUTTON_2_test <= '1'; wait for ciclo*6;
	BUTTON_2_test <= '0';
	wait for ciclo*20;
	
	BUTTON_1_test <= '1'; wait for ciclo*400000;
	BUTTON_1_test <= '0';

	wait for ciclo*1300000;
	
	BUTTON_1_test <= '1'; wait for ciclo*400000;
	BUTTON_1_test <= '0';
	
	wait;
    end process tb;
END test_sistema_arq;























