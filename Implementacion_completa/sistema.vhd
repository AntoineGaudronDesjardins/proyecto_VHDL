library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity sistema is
    port (
        -- ENTRADAS --
        CLK          : in std_logic;
        BUTTON_1     : in std_logic;
        BUTTON_2     : in std_logic;
        BUTTON_RESET : in std_logic; -- Este es el botón de reset

        -- SALIDAS --
        MOTOR_OUT : out std_logic_vector(3 downto 0);
        LED       : out std_logic
    );
end entity;

architecture arch_sistema of sistema is

    -- CODIGO DEL ALUMNO --
    type DNI is array(7 downto 0) of integer range 1 to 10;
    constant D : DNI := (10, 1, 1, 2, 3, 5, 8, 1);

    constant WORD_SIZE     : integer := (D(1) mod 5) + 3;
    constant WORD_FIFO     : integer := D(7) + 5;
    constant FIFO_MAX      : integer := D(0) + 4;
    constant CICLOS_SIZE   : integer := (D(1) mod 5) + 2;
    -- se desea una frecuencia de CLK_SLOW de 100Hz (CLK es 100MHz en el micro)
    constant N_MAX         : integer := 1000000;
    -- el tiempo del filtro es (D3+1)*10ms : corresponde a (D3+1)*1000000 ciclos del reloj
    constant CICLOS_FILTER : integer := ((D(3) mod 5) + 1) * 1000000;

    -- Importacion del componente debouncing
    component debouncing
        generic (
            CICLOS_FILTER : integer := CICLOS_FILTER
        );
        port (
            -- ENTRADAS --
            CLK         : in std_logic;
            RESET       : in std_logic;
            BUTTON_IN   : in std_logic;
            -- SALIDAS --
            BUTTON_OUT  : out std_logic
        );
    end component;
    signal BUTTON_OUT_1 : std_logic;
    signal BUTTON_OUT_2 : std_logic;


    -- Importacion del componente gestor_escritura
    component gestor_escritura
        generic (
            WORD_SIZE    : integer := WORD_SIZE;
            WORD_FIFO    : integer := WORD_FIFO
        );
        port (
            -- ENTRADAS --
            CLK          : in std_logic;
            RESET        : in std_logic;
            BUTTON_1     : in std_logic;
            BUTTON_2     : in std_logic;
            FIFO_FULL    : in std_logic;
            -- SALIDAS --
            WRITE_FIFO   : out std_logic;
            WORD_FIFO_WR : out std_logic_vector(WORD_SIZE-1 downto 0); 
            LED          : out std_logic
        );
    end component;
    signal FIFO_FULL    : std_logic;
    signal WRITE_FIFO   : std_logic;
    signal WORD_FIFO_WR : std_logic_vector(WORD_SIZE-1 downto 0);


    -- Importacion del componente fifo
    component fifo
        generic (
            WORD_SIZE : integer := WORD_SIZE;
            FIFO_MAX  : integer := FIFO_MAX
        ); 
        port (
            -- ENTRADAS --
            CLK          : in std_logic;
            RESET        : in std_logic;
            WRITE_FIFO   : in std_logic;
            READ_FIFO    : in std_logic;
            FIFO_WORD_WR : in std_logic_vector(WORD_SIZE-1 downto 0);
            -- SALIDAS --
            FIFO_WORD_RD : out std_logic_vector(WORD_SIZE-1 downto 0);
            FIFO_EMPTY   : out std_logic;
            FIFO_FULL    : out std_logic
        );
    end component;
    signal READ_FIFO    : std_logic;
    signal FIFO_WORD_RD : std_logic_vector(WORD_SIZE-1 downto 0);
    signal FIFO_EMPTY   : std_logic;


    -- Importacion del componente gestor_lectura
    component gestor_lectura
        generic (
            WORD_SIZE   : integer := WORD_SIZE;
            CICLOS_SIZE : integer := CICLOS_SIZE
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
    end component;
    signal FINISHED : std_logic;
    signal SENTIDO  : std_logic;
    signal CICLOS   : std_logic_vector(CICLOS_SIZE-1 downto 0);
    signal START    : std_logic;
    

    -- Importacion del componente divisor_frecuencia
    component divisor_frecuencia
        generic(
            N_MAX : integer := N_MAX
        );
        port (
            -- ENTRADAS --
            CLK      : in std_logic;
            RESET    : in std_logic;
            -- SALIDAS --
            CLK_SLOW : out std_logic
        );
    end component;
    signal CLK_SLOW : std_logic;
    

    -- Importacion del componente motor_stepper
    component motor_stepper
        generic (
            CICLOS_SIZE : integer := CICLOS_SIZE
        );
        port (
            -- ENTRADAS --
            CLK_SLOW : in std_logic;
            RESET    : in std_logic;
            SENTIDO  : in std_logic;
            CICLOS   : in std_logic_vector(CICLOS_SIZE-1  downto 0);
            START    : in std_logic;
            -- SALIDAS --
            MOTOR_OUT : out std_logic_vector(3 downto 0);
            FINISHED  : out std_logic
        );
    end component;
     
begin

    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente antirebotes para el boton 1
    -- ======================================================================================
    debouncing_inst1: debouncing
        port map(
            -- ENTRADAS --
            CLK         => CLK,
            RESET       => BUTTON_RESET,
            BUTTON_IN   => BUTTON_1,
            -- SALIDAS --
            BUTTON_OUT  => BUTTON_OUT_1
        );

    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente antirebotes para el boton 2
    -- ======================================================================================
    debouncing_inst2: debouncing
        port map(
            -- ENTRADAS --
            CLK         => CLK,
            RESET       => BUTTON_RESET,
            BUTTON_IN   => BUTTON_2,
            -- SALIDAS --
            BUTTON_OUT  => BUTTON_OUT_2
        );

    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente gestor_escritura
    -- ======================================================================================
    gestor_escritura_inst: gestor_escritura 
        port map(
            -- ENTRADAS --
            CLK          => CLK,
            RESET        => BUTTON_RESET,
            BUTTON_1     => BUTTON_OUT_1,
            BUTTON_2     => BUTTON_OUT_2,
            FIFO_FULL    => FIFO_FULL,
            -- SALIDAS --
            WRITE_FIFO   => WRITE_FIFO,
            WORD_FIFO_WR => WORD_FIFO_WR,
            LED          => LED
        );

    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente fifo
    -- ======================================================================================
    fifo_inst : fifo
        port map(
            -- ENTRADAS --
            CLK          => CLK,
            RESET        => BUTTON_RESET,
            WRITE_FIFO   => WRITE_FIFO,
            READ_FIFO    => READ_FIFO,
            FIFO_WORD_WR => WORD_FIFO_WR,
            -- SALIDAS --
            FIFO_WORD_RD => FIFO_WORD_RD,
            FIFO_EMPTY   => FIFO_EMPTY,
            FIFO_FULL    => FIFO_FULL
        );
    
    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente gestor_lectura
    -- ======================================================================================
    gestor_lectura_inst : gestor_lectura
        port map(
            -- ENTRADAS --
            FIFO_EMPTY   => FIFO_EMPTY,
            FIFO_WORD_RD => FIFO_WORD_RD,
            RESET        => BUTTON_RESET,
            CLK          => CLK,
            FINISHED     => FINISHED,
            -- SALIDAS --
            READ_FIFO    => READ_FIFO,
            SENTIDO      => SENTIDO,
            CICLOS       => CICLOS,
            START        => START
        );
    
    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente divisor_frecuencia
    -- ======================================================================================
    divisor_frecuencia_inst : divisor_frecuencia
        port map(
            -- ENTRADAS --
            CLK      => CLK,
            RESET    => BUTTON_RESET,
            -- SALIDAS --
            CLK_SLOW => CLK_SLOW
        );
    
    -- ======================================================================================
    -- Creacion y conexion de la instancia del componente motor_stepper
    -- ======================================================================================
    motor_stepper_inst : motor_stepper
        port map(
            -- ENTRADAS --
            CLK_SLOW  => CLK_SLOW,
            RESET     => BUTTON_RESET,
            SENTIDO   => SENTIDO,
            CICLOS    => CICLOS,
            START     => START,
            -- SALIDAS --
            MOTOR_OUT => MOTOR_OUT,
            FINISHED  => FINISHED
        );

end architecture;