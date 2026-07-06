local set = ya.sync(function(st, url, empty)
  st.empty[url] = empty
  ui.render()
end)

local function setup(st)
  st.empty = {}
  local raw_icon = Entity.icon
  Entity.icon = function(self)
    if not (self._file.cha.is_dir and st.empty[tostring(self._file.url)]) then
      return raw_icon(self)
    end
    local icon = th.icon:match(self._file, { hovered = self._file.is_hovered })
    if not icon or icon.text ~= '󰝰' then
      return raw_icon(self)
    end
    local empty = '󰷏'
    if self._file.is_hovered then
      return empty .. ' '
    else
      return ui.Line(empty .. ' '):style(icon.style)
    end
  end
end

local function fetch(_, job)
  for _, file in ipairs(job.files) do
    local contents = fs.read_dir(file.url, { limit = 1 })
    if contents then
      set(tostring(file.url), #contents == 0)
    end
  end
  return true
end

return { setup = setup, fetch = fetch }
