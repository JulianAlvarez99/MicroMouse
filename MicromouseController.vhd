library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MicromouseController is
    Port (
        clk          : in STD_LOGIC;
        reset        : in STD_LOGIC;
        sensor_front : in STD_LOGIC; -- 1 si detecta una pared al frente
        sensor_left  : in STD_LOGIC; -- 1 si detecta pared a la izquierda
        sensor_right : in STD_LOGIC; -- 1 si detecta pared a la derecha
        cell_count   : in STD_LOGIC_VECTOR(7 downto 0); -- Contador de celdas recorridas
        move_forward : out STD_LOGIC;
        turn_left    : out STD_LOGIC;
        turn_right   : out STD_LOGIC
    );
end MicromouseController;

architecture Behavioral of MicromouseController is
    constant MAZE_SIZE : integer := 4;
    type maze_type is array(0 to MAZE_SIZE-1, 0 to MAZE_SIZE-1) of integer;
    signal maze : maze_type := (others => (others => 255)); -- 255 representa una celda no explorada
    signal current_x, current_y : integer := 0;
    signal facing_direction : integer := 0; -- 0: Norte, 1: Este, 2: Sur, 3: Oeste
begin
    process(clk, reset)
    begin
        if reset = '0' then
            current_x <= 0;
            current_y <= 0;
            facing_direction <= 0;
        elsif rising_edge(clk) then
            -- Condiciones de movimiento y actualización de posición
            if sensor_front = '0' then
                move_forward <= '1';
                case facing_direction is
                    when 0 => current_y <= current_y + 1; -- Norte
                    when 1 => current_x <= current_x + 1; -- Este
                    when 2 => current_y <= current_y - 1; -- Sur
                    when 3 => current_x <= current_x - 1; -- Oeste
                    when others => null;
                end case;

	    elsif sensor_left = '0' then
   	        turn_left <= '1';
				  turn_right <= '0';
				  
                if facing_direction = 0 then
      	        facing_direction <= 3; -- Girar hacia la izquierda desde el norte da oeste
    		else
      		facing_direction <= (facing_direction - 1) mod 4;
   		end if;

            elsif sensor_right = '0' then
                turn_right <= '1';
                facing_direction <= (facing_direction + 1) mod 4;
            else
                -- Si no hay camino disponible, aplica floodfill para encontrar el siguiente paso
                move_forward <= '0';
            end if;
        end if;
    end process;
    process(clk, reset)
    begin
        if reset = '0' then
            -- Inicialización de distancias
            for i in 0 to MAZE_SIZE-1 loop
                for j in 0 to MAZE_SIZE-1 loop
                    maze(i, j) <= i+j; -- Máxima distancia
                end loop;
            end loop;
            maze(0, 0) <= 0; -- Centro del laberinto (cambiar)
        elsif rising_edge(clk) then
            -- Floodfill: actualizar distancias a partir de celdas vecinas
            for i in 0 to MAZE_SIZE-1 loop
                for j in 0 to MAZE_SIZE-1 loop
                    if maze(i, j) /= 16  then
                        -- Si no es una celda no explorada, propaga el valor
                        if i > 0 and maze(i-1, j) > maze(i, j) + 1 then
                            maze(i-1, j) <= maze(i, j) + 1;
                        end if;
                        if i < MAZE_SIZE-1 and maze(i+1, j) > maze(i, j) + 1 then
                            maze(i+1, j) <= maze(i, j) + 1;
                        end if;
                        if j > 0 and maze(i, j-1) > maze(i, j) + 1 then
                            maze(i, j-1) <= maze(i, j) + 1;
                        end if;
                        if j < MAZE_SIZE-1 and maze(i, j+1) > maze(i, j) + 1 then
                            maze(i, j+1) <= maze(i, j) + 1;
                        end if;
                    end if;
                end loop;
            end loop;
        end if;
    end process;
end Behavioral;
