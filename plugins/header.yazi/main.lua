local M = {}

local function cwd()
  return ui.Line {
    ui.Span(
      ui.truncate(
        ya.readable_path(tostring(cx.active.current.cwd.path)),
        { max = 64, rtl = true }
      )
    ):style(th.mgr.cwd),
  }
end

local function search_indicator(icon, text)
  return ui.Line(ui.Span(string.format('%s %s', icon, text)):style(th.mgr.find_keyword))
end

local function search()
  local c = cx.active.current.cwd
  return c.is_search and search_indicator('', c.domain) or ''
end

local function filter()
  local f = cx.active.current.files.filter
  return f and search_indicator('', f) or ''
end

local function finder()
  local f = cx.active.finder
  return f and search_indicator('', f) or ''
end

local function count_badge(style, val)
  return ui.Line {
    ui.Span(''):style(style):reverse(),
    ui.Span(val):style(style),
    ui.Span(''):style(style):reverse(),
  }
end

local function selected()
  local s = #cx.active.selected
  return s > 0 and ui.Line(count_badge(th.mgr.count_selected, string.format('%d', s))) or ''
end

local function yanked()
  local y = #cx.yanked
  return y > 0
      and ui.Line(
        count_badge(
          cx.yanked.is_cut and th.mgr.count_cut or th.mgr.count_copied,
          string.format('%d', y)
        )
      )
    or ''
end

local function space()
  return ui.Span ' '
end

M.setup = function()
  Header:children_remove(1, Header.LEFT)
  local left = { cwd, space, search, filter, finder }
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
