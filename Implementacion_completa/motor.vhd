LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY motor_stepper IS
    GENERIC (
        CICLOS_SIZE : integer := 4    -- MOD (D1,5) +2
    );
    PORT (
        -- ENTRADAS --
        CLK_SLOW    : in std_logic;
        RESET       : in std_logic;
        SENTIDO     : in std_logic;
        CICLOS      : in std_logic_vector(CICLOS_SIZE-1 downto 0);
        START       : in std_logic;
        -- SALIDAS --
        MOTOR_OUT   : out std_logic_vector(3 downto 0);
        FINISHED    : out std_logic
    );
END ENTITY;

ARCHITECTURE arch_motor_stepper OF motor_stepper IS

    -- CODIGO DEL ALUMNO --
    TYPE ESTADOS IS (reposo, orange, orangeyellow, yellow, yellowpink, pink, pinkblue, blue, blueorange, final);
    SIGNAL actual, futuro            : ESTADOS := reposo;
    SIGNAL contador, contador_futuro : INTEGER := 0;
     
BEGIN

    -- PROCESO DE SINCRONIZACION
    PROCESS (CLK_SLOW, RESET)
    BEGIN
        -- RESET ASINCRONO A NIVEL ALTO
        IF (RESET = '1') THEN
            actual   <= reposo;
            contador <= 0;
        ELSIF (rising_edge(CLK_SLOW)) THEN
            -- ACTUALIZACION DEL ESTADO ACTUAL (estado y contador)
            actual   <= futuro;
            contador <= contador_futuro;
        END IF;
    END PROCESS;
    
    -- PROCESO COMBINACIONAL
    PROCESS (actual, contador, SENTIDO, START, CICLOS)
    BEGIN
        CASE actual IS

            WHEN reposo =>
                MOTOR_OUT <= "0000";
                FINISHED <= '0';
                contador_futuro <= 0;
                IF (START = '1') THEN
                    IF(SENTIDO = '1') THEN
                        futuro <= orange;
                    ELSE
                        futuro <= blueorange;
                    END IF;
                END IF;
            
            WHEN orange =>
                MOTOR_OUT <= "1000";
                IF (SENTIDO = '1') THEN
                    futuro <= orangeyellow;
                ELSE
                    contador_futuro <= contador + 1;
                    IF (contador = CICLOS-1) THEN
                        futuro <= final;
                    ELSE
                        futuro <= blueorange;
                    END IF;
                END IF;
            
            WHEN orangeyellow =>
                MOTOR_OUT <= "1100";
                IF (SENTIDO = '1') THEN
                    futuro <= yellow;
                ELSE
                    futuro <= orange;
                END IF;
                
            WHEN yellow =>        
                MOTOR_OUT <= "0100";
                IF (SENTIDO = '1') THEN
                    futuro <= yellowpink;
                ELSE
                    futuro <= orangeyellow;
                END IF;
            
            WHEN yellowpink =>
                MOTOR_OUT <= "0110";
                IF (SENTIDO = '1') THEN
                    futuro <= pink;
                ELSE
                    futuro <= yellow;
                END IF;
                        
            WHEN pink =>        
                MOTOR_OUT <= "0010";
                IF (SENTIDO = '1') THEN
                    futuro <= pinkblue;
                ELSE
                    futuro <= yellowpink;
                END IF;
            
            WHEN pinkblue =>
                MOTOR_OUT <= "0011";
                IF (SENTIDO = '1') THEN
                    futuro <= blue;
                ELSE
                    futuro <= pink;
                END IF;
            
            WHEN blue =>
                MOTOR_OUT <= "0001";
                IF (SENTIDO = '1') THEN
                    futuro <= blueorange;
                ELSE
                    futuro <= pinkblue;
                END IF;
            
            WHEN blueorange =>
                MOTOR_OUT <= "1001";
                IF (SENTIDO = '1') THEN
                    contador_futuro <= contador + 1;
                    IF (contador = CICLOS-1) THEN
                        futuro <= final;
                    ELSE    
                        futuro <= orange;
                    END IF;
                ELSE
                    futuro <= blue;
                END IF;
            
            WHEN final =>
                MOTOR_OUT <= "0000";
                FINISHED <= '1';
                futuro <= reposo;
            
            WHEN OTHERS =>
                MOTOR_OUT <= "0000";
            
        END CASE;
    END PROCESS;

END ARCHITECTURE;
