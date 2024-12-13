-- core

require('session'):setup { sync_yanked = true }

-- git.yazi

THEME.git = THEME.git or {}

THEME.git.ignored = ui.Style():fg 'darkgray'
THEME.git.ignored_sign = '!'

THEME.git.untracked = ui.Style():fg 'yellow'
THEME.git.untracked_sign = '*'

THEME.git.added = ui.Style():fg 'green'
THEME.git.added_sign = '+'

THEME.git.modified = ui.Style():fg 'blue'
THEME.git.modified_sign = '~'

THEME.git.updated = ui.Style():fg 'blue'
THEME.git.updated_sign = '~'

THEME.git.deleted = ui.Style():fg 'red'
THEME.git.deleted_sign = '-'

require('git'):setup()

-- status.yazi

require('status'):setup()