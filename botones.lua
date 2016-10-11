botones = {}
x = 120

for i=1, 6, 1 do
	x = x + 75
	table.insert(botones, {x = x, y = 550, title = i, id = i})
end


function botones.draw()
	for i,v in ipairs(botones) do
		love.graphics.setColor(0,0,0)
		font = love.graphics.newFont("Letra/Righteous-Regular.ttf", 40)
		love.graphics.setFont(font)
		love.graphics.rectangle("line", v.x , v.y , 20, 20)
		love.graphics.print(v.title, v.x, v.y)
	end
end


function DRAW_BOTONES()
	botones.draw()
end