-- core

require('session'):setup { sync_yanked = true }

-- git.yazi

THEME.git_ignored = ui.Style():fg 'darkgray'
THEME.git_ignored_sign = '!'

THEME.git_untracked = ui.Style():fg 'yellow'
THEME.git_untracked_sign = '*'

THEME.git_added = ui.Style():fg 'green'
THEME.git_added_sign = '+'

THEME.git_modified = ui.Style():fg 'blue'
THEME.git_modified_sign = '~'

THEME.git_updated = ui.Style():fg 'blue'
THEME.git_updated_sign = '~'

THEME.git_deleted = ui.Style():fg 'red'
THEME.git_deleted_sign = '-'

require('git'):setup()

-- status.yazi

require 'status'
