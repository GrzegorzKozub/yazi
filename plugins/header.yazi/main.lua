local M = {}

local function cwd()
  return ui.Line {
    ui.Span(
      ui.truncate(ya.readable_path(tostring(cx.active.current.cwd)), { max = 64, rtl = true })
    )
      :style(th.mgr.cwd),
  }
end

local function count(style, val)
  return ui.Line {
    ui.Span(''):style(style):reverse(),
    ui.Span(val):style(style),
    ui.Span(''):style(style):reverse(),
  }
end

local function selected()
  local s = #cx.active.selected
  return s > 0 and ui.Line(count(th.mgr.count_selected, string.format('%d', s))) or ''
end

local function yanked()
  local y = #cx.yanked
  return y > 0
      and ui.Line(
        count(
          cx.yanked.is_cut and th.mgr.count_cut or th.mgr.count_copied,
          string.format('%d', y)
        )
      )
    or ''
end

-- function Header:flags()
--   local cwd = self._current.cwd
--   local filter = self._current.files.filter
--   local finder = self._tab.finder
--   local t = {}
--   if cwd.is_search then
--     t[#t + 1] = string.format('search: %s', cwd.domain)
--   end
--   if filter then
--     t[#t + 1] = string.format('filter: %s', filter)
--   end
--   if finder then
--     t[#t + 1] = string.format('find: %s', finder)
--   end
--   return #t == 0 and '--' or ' (' .. table.concat(t, ', ') .. ')'
-- end

local function space()
  return ui.Span ' '
end

M.setup = function()
  Header:children_remove(1, Header.LEFT)
  local left = { cwd }
  for i, value in ipairs(left) do
    Header:children_add(value, i, Header.LEFT)
  end
  Header:children_remove(1, Header.RIGHT)
  local right = { selected, space, yanked }
  for i, value in ipairs(right) do
    Header:children_add(value, i, Header.RIGHT)
  end
end

return M
