return {
  entry = function()
    local hovered = cx.active.current.hovered
    ya.manager_emit(hovered and hovered.cha.is_dir and 'enter' or 'open', { hovered = true })
  end,
}
