posiciones = {}
y = 30

    for i = 1,6,1 do
		x = 120
		y = y + 75
        row = {}
        for j = 1,6,1 do
			x = x + 75
            table.insert(row,{x = x, y = y, radio = 30, ocupado = false, color = "blanco", ocupadoA = false})
        end
        table.insert(posiciones,row)
    end


function posiciones.draw()
    for i,row in ipairs(posiciones) do
        for y,column in ipairs(row) do
			love.graphics.setColor(255, 255, 255)
			love.graphics.circle("fill", column.x, column.y, column.radio)
        end
    end
end

function fondo()
	love.graphics.setColor(0, 0, 100)
	love.graphics.rectangle("fill", 127, 40, 500, 500)
end

function DRAW_POSICIONES()
	fondo()
	posiciones.draw()
end
