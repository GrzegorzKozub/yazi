-- core

require('session'):setup { sync_yanked = true }

ps.sub('ind-app-title', function(args)
  args.value = tostring(cx.active.current.cwd)
  return args
end)

-- git.yazi

th.git = th.git or {}

th.git.ignored = ui.Style():fg 'darkgray'
th.git.ignored_sign = '!'

th.git.untracked = ui.Style():fg 'yellow'
th.git.untracked_sign = '*'

th.git.added = ui.Style():fg 'green'
th.git.added_sign = '+'

th.git.modified = ui.Style():fg 'blue'
th.git.modified_sign = '~'

th.git.updated = ui.Style():fg 'blue'
th.git.updated_sign = '~'

th.git.deleted = ui.Style():fg 'red'
th.git.deleted_sign = '-'

require('git'):setup()

-- my-header.yazi

require('my-header'):setup()

-- my-icon.yazi

require('my-icon'):setup()

-- my-status.yazi

require('my-status'):setup()
