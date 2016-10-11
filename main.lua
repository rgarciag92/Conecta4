--------------------------------------------------------
-- 				Clases a utilizar					  --
--------------------------------------------------------
require "posiciones"   -- Contiene la información del tablero.
require "jugadorUno"   -- Contiene la información del primer jugador.
require "botones" 	   -- Contiene la información de los botones para jugar.
require "jugadorDos"   -- Contiene la información del segundo jugador.

--------------------------------------------------------
-- 				Variables globales					  --
--------------------------------------------------------
turno = "verde"      -- Turno para el jugador.
estado = "jugando"	 -- Estado del juego JUGANDO o TERMINADO.
color = "blanco"     -- Tipo de ficha a colocar.
opciones = {}		 -- Primer nivel de ramas de posibles tiros (BFS & UC).
opcionesT = {}       -- Siguientes niveles de ramas para posibles tiros (BFS).
mejorOpcion = {}     -- Mejor opción del último nivel (BFS).
costoTotal = 0       --Costo usado para el UC.
colorGanador = "blanco"    --Dato usado para saber en que jugador se basa el análisis del UC. 
tipoIA = 0     --Bandera que permite saber cuántas veces ha sido ocupado el cambio de estado.
--------------------------------------------------------------
-- 			    	Funciones de ayuda  					--
--------------------------------------------------------------
-- Función de ayuda para el copiado completo de la matriz.
local function deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == 'table' then
            v = deepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

-- Limpia todos los registros de la matriz. 
local function clean(matriz)
	for i= 1, #matriz, 1 do
		matriz[i] = nil
	end
end

----------------------------------------------------------
--       	  	        Función BFS 	   		        --
----------------------------------------------------------
-- Implementación de los diferentes niveles de un BFS.
function BFS(matriz, recursivo, xO, yO, iO, jO, colorT)
	-- Si es recursivo no se modifican las variables X, Y, I, J del padre
	if recursivo then 
		for columna = 1, 6, 1 do
			for fila = 6, 1, -1 do
				-- Se busca el primer espacio libre desocupado de una columna (de abajo a arriba)
				if matriz[fila][columna].ocupado == false then
					niveles = deepCopy(matriz)
					niveles[fila][columna].ocupado = true
					niveles[fila][columna].color = colorT
					table.insert(opciones, {opcion = niveles, i = iO, j = jO, x = xO, y = yO})
					break
				end
			end
		end
	else 
	-- Si no es recursivo (primer nivel) entonces se guardan las variables X, Y, I , J del padre
		for columna = 1, 6, 1 do
			for fila = 6, 1, -1 do
				-- Se busca el primer espacio libre desocupado de una columna (de abajo a arriba)
				if matriz[fila][columna].ocupado == false then
					niveles = deepCopy(matriz)
					niveles[fila][columna].ocupado = true
					niveles[fila][columna].color = colorT
					table.insert(opciones, {opcion = niveles, i = fila, j = columna, x = matriz[fila][columna].x, y = matriz[fila][columna].y})
					break
				end
			end
		end
	end
end

-- Selección de la mejor opcion de acuerdo al ultimo nivel 
function bestOption_BFS(arreglo, colorB)
	-- Revisa por columna de una opcion para ver cual es la que mas fichas del mismo color tiene
	for i = 1, #arreglo, 1 do
		cuentaColumna = 0
		for fila = 1, 6, 1 do
			for columna = 6, 1, -1 do
				-- Si no hay fichas del mismo color juntas en una columna se pasa a la siguiente columna
				if arreglo[i].opcion[columna][fila].color ~= colorB then
					break
				else 
					-- Se lleva una cuenta de la mayor cantidad de fichas para guardar la mejor
					cuentaColumna = cuentaColumna + 1
				end
			end
		end
					-- En caso de que ya haya una opcion guardada se verifica que la cuenta de fichas juntas sea mayor a la de ya almacenada
			if table.getn(mejorOpcion) ~= 0 and mejorOpcion[1].cuenta <= cuentaColumna then 
				-- table.remove(mejorOpcion, 1)
				table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = cuentaColumna})
			-- En caso de que sea la primera vez que se llena la opcion entonces se introduce la cuentaColumna
			elseif table.getn(mejorOpcion) == 0 then
				table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = cuentaColumna})
			end
	end	
end

--------------------------------------------------------------
--       	  	  Función UniformCost (UC) 	   		        --
--------------------------------------------------------------
function UC(matriz, colorT)
	for columna = 1, 6, 1 do
		for fila = 6, 1, -1 do
			-- Se busca el primer espacio libre desocupado de una columna (de abajo a arriba).
			if matriz[fila][columna].ocupado == false then
				niveles = deepCopy(matriz)
				niveles[fila][columna].ocupado = true
				niveles[fila][columna].color = colorT
				table.insert(opciones, {opcion = niveles, i = fila, j = columna, x = matriz[fila][columna].x, y = matriz[fila][columna].y})
				break
			end
		end
	end
end

--Se le tiene que pasar como parámetro el arreglo opciones.
function bestOption_UC(arreglo, colorB)
	colorRival = ""
	mejorCosto = 0
	
	if colorB == "verde" then
		colorRival = "rojo"
	else 
		colorRival = "verde"
	end 
	
	for i = 1, #arreglo, 1 do
		costoTotal = 0
		--CASO 1 = Costo -> 9
		-- Se verifica en todas las direcciones en busca de 4 fichas del mismo color del oponente.
		revisa(arreglo[i].i, arreglo[i].j, colorRival, true, 2)
		
		--Si es 8 y el color de la ficha ganadora es la del oponente, se toma como costo máximo. 
		if costoTotal == 8 and colorGanador == colorRival then
			-- En caso de que ya haya una opcion guardada se verifica que el costo sea mayor al ya almacenado.
			if table.getn(mejorOpcion) ~= 0 and mejorOpcion[1].cuenta < costoTotal then 
				table.remove(mejorOpcion, 1)
				table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = costoTotal})
				colorGanador = "blanco"
			-- En caso de que sea la primera vez que se llena la opcion entonces se introduce el costo calculado.
			elseif table.getn(mejorOpcion) == 0 then
				table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = costoTotal})
				colorGanador = "blanco"
			end
		elseif costoTotal ~= 8 and colorGanador == "blanco" then
			--CASO 2 = Costo -> 8.
			-- Se verifica en todas las direcciones en busca de 4 fichas del mismo color del jugador en turno.
			revisa(arreglo[i].i, arreglo[i].j, colorB, true, 2)
			--Si es 8 y el color de la ficha ganadora es la del oponente, se toma como costo máximo. 
			if costoTotal == 8 and colorGanador == colorB then
				costoTotal = 9
				-- En caso de que ya haya una opcion guardada se verifica que el costo sea mayor al ya almacenado.
				if table.getn(mejorOpcion) ~= 0 and mejorOpcion[1].cuenta < costoTotal then 
					table.remove(mejorOpcion, 1)
					table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = costoTotal})
					colorGanador = "blanco"
				-- En caso de que sea la primera vez que se llena la opcion entonces se introduce el costo calculado.
				elseif table.getn(mejorOpcion) == 0 then
					table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = costoTotal})
					colorGanador = "blanco"
				end
			elseif costoTotal ~= 8 and colorGanador == "blanco" then
				--CASO 3 = Costo -> Mínimo 1 - Máximo 7
				--Verificar que costo es el mayor y tirar en esa posición. 
				-- Revisa lugares adyacentes para averiguar el costo. Por una ficha en cualquiera de sus lugares adyacentes se suma un 1. 
				
				--Chequeo -> ABAJO
				if arreglo[i].i ~= 6 then
					if arreglo[i].opcion[arreglo[i].i + 1][arreglo[i].j].color == colorB then
						costoTotal = costoTotal + 1
					end
				end 
				--Chequeo -> DERECHA
				if arreglo[i].j ~= 6 then
					if arreglo[i].opcion[arreglo[i].i][arreglo[i].j + 1].color == colorB then
						costoTotal = costoTotal + 1
					end
				end 
				--Chequeo -> IZQUIERDA
				if arreglo[i].j ~= 1 then
					if arreglo[i].opcion[arreglo[i].i][arreglo[i].j - 1].color == colorB then
						costoTotal = costoTotal + 1
					end
				end 
				--Chequeo -> DIAGONAL ABAJO-DERECHA
				if arreglo[i].i ~= 6 and arreglo[i].j ~= 6 then
					if arreglo[i].opcion[arreglo[i].i + 1][arreglo[i].j + 1].color == colorB then
						costoTotal = costoTotal + 1
					end
				end 
				--Chequeo -> DIAGONAL ABAJO-IZQUIERDA
				if arreglo[i].i ~= 6 and arreglo[i].j ~= 1 then
					if arreglo[i].opcion[arreglo[i].i + 1][arreglo[i].j - 1].color == colorB then
						costoTotal = costoTotal + 1
					end
				end 
				--Chequeo -> DIAGONAL ARRIBA-DERECHA
				if arreglo[i].i ~= 1 and arreglo[i].j ~= 6 then
					if arreglo[i].opcion[arreglo[i].i - 1][arreglo[i].j + 1].color == colorB then
						costoTotal = costoTotal + 1
					end
				end 
				--Chequeo -> DIAGONAL ARRIBA-IZQUIERDA
				if arreglo[i].i ~= 1 and arreglo[i].j ~= 1 then
					if arreglo[i].opcion[arreglo[i].i - 1][arreglo[i].j - 1].color == colorB then
						costoTotal = costoTotal + 1
					end
				end
				
				-- En caso de que ya haya una opcion guardada se verifica que la cuenta de fichas juntas sea mayor a la de ya almacenada
				if table.getn(mejorOpcion) ~= 0 and mejorOpcion[1].cuenta < costoTotal then 
					table.remove(mejorOpcion, 1)
					table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = costoTotal})
				-- En caso de que sea la primera vez que se llena la opcion entonces se introduce la cuentaColumna
				elseif table.getn(mejorOpcion) == 0 then
					table.insert(mejorOpcion, {matriz = arreglo[i].opcion, x = arreglo[i].x, y = arreglo[i].y, i = arreglo[i].i, j = arreglo[i].j, cuenta = costoTotal})
				end
			end
		end
	end	
end

--------------------------------------------------------
--          	     Funciones de LOVE			      --
--------------------------------------------------------
function love.load()
	love.graphics.setBackgroundColor(255,255, 255)
end 

function love.update(dt)
	 if turno == "verde" and estado == "jugando" then
		IA_BFS()	
	 end
	 
	if turno == "rojo" and estado == "jugando" then
		IA_UC()
	end
end

function love.draw()	
	DRAW_POSICIONES()
	DRAW_JUGADORUNO()
	DRAW_JUGADORDOS()
	DRAW_BOTONES()
end

function love.mousepressed(x,y)
	for i, v in ipairs(botones) do
		if turno == "verde" and estado == "jugando" then
			if 	x > v.x and
				x < v.x + font:getWidth(v.title) and
				y > v.y and
				y < v.y + font:getHeight() then
					exitFlag = false
					for i = #posiciones, 1, -1 do
						for j= #row, 1, -1 do
							if (posiciones[i][j].x == v.x) and (posiciones[i][j].color == "blanco") then
								posiciones[i][j].ocupado = true
								posiciones[i][j].color = "verde"
								revisa(i, j, posiciones[i][j].color, true)
								jugadorUno.spawn(v.x, posiciones[i][j].y)
								exitFlag = true
								break
							end
						end
						if exitFlag then
							break
						end
					end
				turno = "rojo"
			end
		end
	end
end

--------------------------------------------------------------------
--      	     Funciones de revisión de fichas			      --
--------------------------------------------------------------------
function revisa(i, j, color, continue, tipoIA)
	iTemp = i
	jTemp = j
	cuentaDL = 0 -- cuenta derecha
	cuentaIL = 0 -- cuenta izquierda
	cuentaDDUL = 0 -- cuenta diagonal derecha arriba
	cuentaDDDL = 0 -- cuenta diagonal derecha abajo
	cuentaDIUL = 0 -- cuenta diagonal izquierda arriba
	cuentaDIDL = 0 -- cuenta diagonal izquierda abajo
	cuentaBL = 0 -- cuenta abajo
	
	-- Revisión ABAJO
	while continue do
		if iTemp ~= 6 then
			if posiciones[iTemp+1][jTemp].color ~= color then
				continue = false
			elseif posiciones[iTemp+1][jTemp].color == color then
				cuentaBL = cuentaBL + 1
				iTemp = iTemp + 1
			end
		else 
			continue = false
		end
		if cuentaBL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1
		end
	end	
	
	Continue = true
	iTemp = i

	-- Revisión DERECHA
	while continue do
		if jTemp ~= 6 then
			if posiciones[iTemp][jTemp+1].color ~= color then
				continue = false
			elseif posiciones[iTemp][jTemp+1].color == color then
				jTemp = jTemp + 1
				cuentaDL = cuentaDL + 1
			end
		else 
			continue = false
		end
		if cuentaDL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1 
		end
	end
	
	continue = true
	jTemp = j
	
	-- Revisión IZQUIERDA
	while continue do
		if jTemp ~= 1 then
			if posiciones[iTemp][jTemp-1].color ~= color then
				continue = false
			elseif posiciones[iTemp][jTemp-1].color == color then
				cuentaIL = cuentaIL + 1
				jTemp = jTemp - 1
			end
		else 
			continue = false
		end
		if cuentaIL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1 
		end
	end	
	
	-- Revisión AMBOS LADOS
	if cuentaDL + cuentaIL >= 3 then
		costoTotal = 8
		if tipoIA == 2 then 
			colorGanador = color
		elseif tipoIA == 1 then 
			estado = "ganado"
		end
		return 1
	end
	
	continue = true
	jTemp = j
	
	-- Revisión DIAGONAL DERECHA ARRIBA
	while continue do
		if iTemp ~= 1 and jTemp ~= 6 then
			if posiciones[iTemp - 1][jTemp+1].color ~= color then
				continue = false
			elseif posiciones[iTemp - 1][jTemp+1].color == color then
				cuentaDDUL = cuentaDDUL + 1
				iTemp = iTemp - 1
				jTemp = jTemp + 1
			end
		else 
			continue = false
		end
		if cuentaDDUL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1
		end
	end
	
	continue = true
	iTemp = i
	jTemp = j
	
	-- Revisión DIAGONAL IZQUIERDA ABAJO
	while continue do
		if iTemp ~= 6 and jTemp ~= 1 then
			if posiciones[iTemp+1][jTemp-1].color ~= color then
				continue = false
			elseif posiciones[iTemp+1][jTemp-1].color == color then
				cuentaDIDL = cuentaDIDL + 1
				iTemp = iTemp + 1
				jTemp = jTemp - 1
			end
		else 
			continue = false
		end
		if cuentaDIDL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1
		end
	end	
	
	-- Revisión AMBOS LADOS (DIAGONAL)
	if cuentaDDUL + cuentaDIDL >= 3 then
		costoTotal = 8
		colorGanador = color
		if tipoIA == 2 then 
			colorGanador = color
		elseif tipoIA == 1 then 
			estado = "ganado"
		end
		return 1
	end
	
	continue = true
	iTemp = i
	jTemp = j 
	
	-- Revisión DIAGONAL DERECHA ABAJO
	while continue do
		if iTemp ~= 6 and jTemp ~= 6 then
			if posiciones[iTemp + 1][jTemp+1].color ~= color then
				continue = false
			elseif posiciones[iTemp + 1][jTemp+1].color == color then
				cuentaDDDL = cuentaDDDL + 1
				iTemp = iTemp + 1
				jTemp = jTemp + 1
			end
		else 
			continue = false
		end
		if cuentaDDDL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1
		end
	end
	
	continue = true
	iTemp = i
	jTemp = j
	
	-- Revisión DIAGONAL IZQUIERDA ARRIBA
	while continue do
		if iTemp ~= 1 and jTemp ~= 1 then
			if posiciones[iTemp-1][jTemp-1].color ~= color then
				continue = false
			elseif posiciones[iTemp-1][jTemp-1].color == color then
				cuentaDIUL = cuentaDIUL + 1
				iTemp = iTemp - 1
				jTemp = jTemp - 1 
			end
		else 
			continue = false
		end
		if cuentaDIUL >= 3 then
			costoTotal = 8
			if tipoIA == 2 then 
				colorGanador = color
			elseif tipoIA == 1 then 
				estado = "ganado"
			end
			return 1
		end
	end	
	
	-- Revisa AMBOS LADOS
	if cuentaDDDL + cuentaDIUL >= 3 then
		costoTotal = 8
		if tipoIA == 2 then 
			colorGanador = color
		elseif tipoIA == 1 then 
			estado = "ganado"
		end
		return 1
	end
	
	continue = true
	iTemp = i
	jTemp = j
	
end

------------------------------------------------------------------------------------
--      		Funciones de Inteligencia de uno de los jugadores (BFS)		      --
------------------------------------------------------------------------------------
function IA_BFS()
	-- Se hace una variable temporal del turno para mandarla como parametro y modificarla.
	color = turno
	BFS(posiciones, false, 0, 0, 0, 0, color)
	
	-- Cantidad de niveles a buscar dentro del arbol
	for i= 1, 3, 1 do
		-- Se limpian las tablas cada vez que se llega a un nivel
		clean(opcionesT)
		opcionesT = deepCopy(opciones)
		clean(opciones)
		-- Se recorre la tabla de las opciones
		for j= 1, #opcionesT, 1 do
			-- Dependiendo del turno se cambia para tener diferentes tiros
			if color == "verde" then
				color = "rojo"
			else 
				color = "verde"
			end
			BFS(opcionesT[j].opcion, true, opcionesT[j].x, opcionesT[j].y, opcionesT[j].i, opcionesT[j].j, color)
		end
	end	

	-- Se selecciona la mejor opcion de acuerdo al ultimo nivel
	bestOption_BFS(opcionesT, turno)
	
	math.randomseed( os.time() )
	rand = math.random(1, #mejorOpcion)
	mejorOpcionJ = mejorOpcion[rand].j
	mejorOpcionI = mejorOpcion[rand].i
	mejorOpcionX = mejorOpcion[rand].x
	mejorOpcionY = mejorOpcion[rand].y
	
	-- Se vacian las tablas para el siguiente turno
	clean(opcionesT)
	clean(opciones)

	-- Se coloca como ocupada y el tipo de ficha que fue
	posiciones[mejorOpcionI][mejorOpcionJ].ocupado = true
	posiciones[mejorOpcionI][mejorOpcionJ].color = turno
	
	-- Se crean las fichas de acuerdo al turno 
	if turno == "verde" and estado == "jugando" then
		jugadorUno.spawn(mejorOpcionX, mejorOpcionY)
		-- Se verifica en todas las direcciones en busca de 4 fichas del mismo color
		revisa(mejorOpcionI, mejorOpcionJ, turno, true, 1)
	elseif turno == "rojo" and estado == "jugando" then 
		jugadorDos.spawn(mejorOpcionX, mejorOpcionY)
		-- Se verifica en todas las direcciones en busca de 4 fichas del mismo color
		revisa(mejorOpcionI, mejorOpcionJ, turno, true, 1)
	end
	
	-- Se vacía la mejorOpcion para el siguiente turno	
	clean(mejorOpcion)
	
	-- Se cambia el turno al siguiente jugador
	if turno == "verde" then
		turno = "rojo"
	elseif turno == "rojo"  then
		turno = "verde"
	end
end

------------------------------------------------------------------------------------
--      		Funciones de Inteligencia de uno de los jugadores (UniformCost)   --
------------------------------------------------------------------------------------
function IA_UC()
	-- Se hace una variable temporal del turno para mandarla como parametro y modificarla.
	color = turno
	UC(posiciones,color)
	
	--Se analizan los tiros viables para la asignación de costos y posteriormente para escoger el tiro apropiado.
	bestOption_UC(opciones,color)

	-- Se vacian las tablas para el siguiente turno
	clean(opciones)
	
	-- Se coloca como ocupada y el tipo de ficha que fue
	posiciones[mejorOpcion[1].i][mejorOpcion[1].j].ocupado = true
	posiciones[mejorOpcion[1].i][mejorOpcion[1].j].color = turno

	
	-- Se crean las fichas de acuerdo al turno 
	if turno == "verde" and estado == "jugando" then
		jugadorUno.spawn(mejorOpcion[1].x, mejorOpcion[1].y)
		-- Se verifica en todas las direcciones en busca de 4 fichas del mismo color
		revisa(mejorOpcion[1].i, mejorOpcion[1].j, turno, true, 1)
	elseif turno == "rojo" and estado == "jugando" then 
		jugadorDos.spawn(mejorOpcion[1].x, mejorOpcion[1].y)
		-- Se verifica en todas las direcciones en busca de 4 fichas del mismo color
		revisa(mejorOpcion[1].i, mejorOpcion[1].j, turno, true, 1)
	end
	
	-- Se vacía la mejorOpcion para el siguiente turno	
	table.remove(mejorOpcion, 1)

	-- Se cambia el turno al siguiente jugador
	if turno == "verde" then
		turno = "rojo"
	elseif turno == "rojo" then
		turno = "verde"
	end
end