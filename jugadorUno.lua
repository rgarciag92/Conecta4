jugadorUno = {}

function jugadorUno.spawn(x, y)
	table.insert(jugadorUno, {x = x, y = y, color = "verde", radio = 30})
end


function jugadorUno.draw()
	for i, v in ipairs(jugadorUno) do
		love.graphics.setColor(0, 255, 0)
		love.graphics.circle("fill", v.x, v.y, v.radio)	
	end
end

function DRAW_JUGADORUNO()
	jugadorUno.draw()
end