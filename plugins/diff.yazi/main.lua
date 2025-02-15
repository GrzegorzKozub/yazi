local M = {}

-- local get_paths = ya.sync(function()
--   local paths, selected = {}, nil
--   for _, value in pairs(cx.active.selected) do
--     paths[#paths + 1] = tostring(value)
--   end
--   if #paths == 0 then
--     local h = cx.active.current.hovered.url
--     paths[1] = tostring(h)
--     selected = h:name()
--   else
--     selected = #paths
--   end
--   return paths, selected
-- end)
--
-- M.entry = function()
--   local paths, selected = get_paths()
--   local total, err = get_total(paths)
--   if err then
--     ya.notify { content = err, level = 'error', timeout = 3, title = 'Size' }
--     return
--   end
--   ya.notify {
--     content = (type(selected) == 'string' and selected .. ': ' or selected .. ' selected: ')
--       .. total,
--     -- level = 'info',
--     timeout = 3,
--     title = 'Size',
--   }
-- end

return M

