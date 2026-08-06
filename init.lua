-- core

require('session'):setup { sync_yanked = true }

ps.sub('ind-app-title', function(args)
  args.value = tostring(cx.active.current.cwd)
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
