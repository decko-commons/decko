
basket[:tasks] = []

# to add an admin task:
#
# basket[:tasks] << {
#   name: NAME,
#   irreversible: TRUE/FALSE,
#   execute_policy: -> { TASK_CODE },
#   stats: {
#     title: TITLE_STRING,
#     count: -> { COUNT_CODE },
#     link_text: LINK_STRING,
#     task: 
#   }
# }