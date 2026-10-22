-- core

require('session'):setup { sync_yanked = true }

ps.sub('ind-app-title', function(args)
  local c = cx.active.current.cwd
  local title = c.spec.scheme == 'place' and tostring(c.path) == '/' and 'This PC'
    or ya.readable_path(tostring(c.path))
  args.value = ui.truncate(title, { max = 32, rtl = true })
  return args
end)

-- git.yazi

require('git'):setup()

-- my-header.yazi

require('my-header'):setup()

-- my-icon.yazi

require('my-icon'):setup()

-- my-status.yazi

require('my-status'):setup()
