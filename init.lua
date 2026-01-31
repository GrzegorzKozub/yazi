-- core

require('session'):setup { sync_yanked = true }

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

-- header.yazi

require('my-header'):setup()

-- status.yazi

require('my-status'):setup()
