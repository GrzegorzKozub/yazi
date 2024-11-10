--- @sync entry

local M = {}

function M.entry(st)
  if not st.curr then
    st.orig, st.curr = Tab.layout, 'maximized'
    Tab.layout = function(self)
      self._chunks = ui.Layout()
        :direction(ui.Layout.HORIZONTAL)
        :constraints({
          ui.Constraint.Percentage(0),
          ui.Constraint.Percentage(0),
          ui.Constraint.Percentage(100),
        })
        :split(self._area)
    end
  elseif st.curr == 'maximized' then
    st.curr = 'hidden'
    Tab.layout = function(self)
      local all = MANAGER.ratio.parent + MANAGER.ratio.current
      self._chunks = ui.Layout()
        :direction(ui.Layout.HORIZONTAL)
        :constraints({
          ui.Constraint.Ratio(MANAGER.ratio.parent, all),
          ui.Constraint.Ratio(MANAGER.ratio.current, all),
          ui.Constraint.Length(1),
        })
        :split(self._area)
    end
  else
    Tab.layout, st.orig, st.curr = st.orig, nil, nil
  end
  ya.app_emit('resize', {})
end

return M
