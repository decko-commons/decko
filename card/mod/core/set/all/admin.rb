
basket[:tasks] = {}
# to add an admin task:
#
# basket[:tasks][TASK_NAME] = {
#   irreversible: TRUE/FALSE,
#   execute_policy: -> { TASK_CODE },
#   mod: MODNAME
# }
#
# Then add two lines in the locales containing the link text and the description:

#   MOD_task_TASK_NAME_link_text: LINK_TEXT
#   MOD_task_TASK_NAME_description: DESCRIPTION