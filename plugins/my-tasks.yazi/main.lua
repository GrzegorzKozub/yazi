local M = {}

M.setup = function()
  local redraw = Tasks.redraw
  function Tasks:redraw()
    local elements = redraw(self)
    for i = 1, #elements // 4 do
      if i ~= cx.tasks.cursor + 1 then
        local title, bar = (i - 1) * 4 + 1, i * 4
        elements[title] = elements[title]:style(th.pick.inactive)
        elements[bar] = elements[bar]:style(th.pick.inactive)
      end
    end
    return elements
  end
end

return M
