--
-- term.lua
-- Additions to the 'term' namespace.
-- Copyright (c) 2017 Blizzard Entertainment and the Premake project
--

-- default colors.
term.black       = 0
term.blue        = 1
term.green       = 2
term.cyan        = 3
term.red         = 4
term.purple      = 5
term.brown       = 6
term.lightGray   = 7
term.gray        = 8
term.lightBlue   = 9
term.lightGreen  = 10
term.lightCyan   = 11
term.lightRed    = 12
term.magenta     = 13
term.yellow      = 14
term.white       = 15

-- colors for specific purpose.
term.warningColor = term.magenta
term.errorColor   = term.lightRed

-- color stack implementation.
term._colorStack = {}

function term.pushColor(color)
	local old = term.getTextColor()
	table.insert(term._colorStack, old)

	term.setTextColor(color)
end

function term.popColor()
	if #term._colorStack > 0 then
		local color = table.remove(term._colorStack)
		term.setTextColor(color)
	end
end
