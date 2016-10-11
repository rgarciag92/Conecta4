jugadorDos = {}

function jugadorDos.spawn(x, y)
	table.insert(jugadorDos, {x = x, y = y, color = "verde", radio = 30})
end


function jugadorDos.draw()
	for i, v in ipairs(jugadorDos) do
		love.graphics.setColor(255, 0, 0)
		love.graphics.circle("fill", v.x, v.y, v.radio)	
	end
end

function DRAW_JUGADORDOS()
	jugadorDos.draw()
end