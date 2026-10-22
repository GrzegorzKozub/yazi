-- core

require('session'):setup { sync_yanked = true }

ps.sub('ind-app-title', function(args)
  local c = cx.active.current.cwd
  local path = tostring(c.path)
  args.value = c.spec.scheme == 'place' and path == '/' and 'This PC'
    or ya.readable_path(path) == '~' and '~'
    or c.name
    or path
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
