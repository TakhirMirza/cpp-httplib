/*
 * Interface: Dashboard
 * Description: Main application dashboard template with common widgets
 * Created: Template
 */

a!localVariables(
  /* Local Variables */
  local!refreshCounter: 0,
  local!currentUser: loggedInUser(),
  local!userTasks: {},
  local!recentActivities: {},
  local!systemMetrics: {},
  
  /* Interface Layout */
  a!headerContentLayout(
    header: a!cardLayout(
      contents: {
        a!richTextDisplayField(
          value: a!richTextItem(
            text: "Welcome to the Application Dashboard",
            size: "LARGE",
            style: "STRONG"
          )
        ),
        a!richTextDisplayField(
          value: a!richTextItem(
            text: "Hello " & user(local!currentUser, "firstName") & "!",
            size: "MEDIUM"
          )
        )
      },
      style: "ACCENT",
      marginBelow: "STANDARD"
    ),
    contents: {
      /* Quick Actions Section */
      a!cardLayout(
        contents: {
          a!richTextDisplayField(
            value: a!richTextItem(
              text: "Quick Actions",
              size: "MEDIUM",
              style: "STRONG"
            )
          ),
          a!buttonArrayLayout(
            buttons: {
              a!buttonWidget(
                label: "Create New Task",
                icon: "plus-circle",
                style: "PRIMARY",
                size: "SMALL",
                saveInto: {
                  /* Navigate to task creation interface */
                  a!startProcess(
                    processModel: cons!TASK_MANAGEMENT_PROCESS,
                    processParameters: {},
                    onSuccess: a!save(local!refreshCounter, local!refreshCounter + 1)
                  )
                }
              ),
              a!buttonWidget(
                label: "View All Tasks",
                icon: "list",
                style: "SECONDARY",
                size: "SMALL",
                link: a!dynamicLink(
                  value: cons!TASK_LIST_INTERFACE
                )
              ),
              a!buttonWidget(
                label: "User Profile",
                icon: "user",
                style: "SECONDARY",
                size: "SMALL",
                link: a!dynamicLink(
                  value: cons!USER_PROFILE_INTERFACE
                )
              )
            },
            align: "START"
          )
        },
        marginBelow: "STANDARD"
      ),
      
      /* Dashboard Content Grid */
      a!columnsLayout(
        columns: {
          /* Left Column - My Tasks */
          a!columnLayout(
            contents: {
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: a!richTextItem(
                      text: "My Tasks",
                      size: "MEDIUM",
                      style: "STRONG"
                    )
                  ),
                  a!gridField(
                    data: local!userTasks,
                    columns: {
                      a!gridColumn(
                        label: "Task",
                        sortField: "title",
                        value: a!linkField(
                          links: a!dynamicLink(
                            value: fv!row.id,
                            saveInto: {
                              /* Navigate to task details */
                            }
                          ),
                          linkText: fv!row.title
                        )
                      ),
                      a!gridColumn(
                        label: "Priority",
                        sortField: "priority",
                        value: a!tagField(
                          tags: a!tagItem(
                            text: fv!row.priority,
                            backgroundColor: if(
                              fv!row.priority = "High",
                              "NEGATIVE",
                              if(
                                fv!row.priority = "Medium",
                                "ACCENT",
                                "SECONDARY"
                              )
                            )
                          )
                        )
                      ),
                      a!gridColumn(
                        label: "Due Date",
                        sortField: "dueDate",
                        value: text(fv!row.dueDate, "MM/DD/YYYY")
                      )
                    },
                    pageSize: 5,
                    showWhen: length(local!userTasks) > 0,
                    emptyGridMessage: "No tasks assigned to you"
                  )
                }
              )
            },
            width: "MEDIUM"
          ),
          
          /* Right Column - Recent Activity & Metrics */
          a!columnLayout(
            contents: {
              /* Recent Activity Card */
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: a!richTextItem(
                      text: "Recent Activity",
                      size: "MEDIUM",
                      style: "STRONG"
                    )
                  ),
                  a!forEach(
                    items: local!recentActivities,
                    expression: a!richTextDisplayField(
                      value: {
                        a!richTextItem(
                          text: fv!item.description,
                          size: "SMALL"
                        ),
                        char(10),
                        a!richTextItem(
                          text: text(fv!item.timestamp, "MM/DD/YYYY hh:mm AM/PM"),
                          size: "SMALL",
                          style: "EMPHASIS"
                        )
                      }
                    )
                  )
                },
                marginBelow: "STANDARD"
              ),
              
              /* System Metrics Card */
              a!cardLayout(
                contents: {
                  a!richTextDisplayField(
                    value: a!richTextItem(
                      text: "System Metrics",
                      size: "MEDIUM",
                      style: "STRONG"
                    )
                  ),
                  a!gaugeField(
                    label: "Task Completion Rate",
                    percentage: local!systemMetrics.taskCompletionRate,
                    primaryText: local!systemMetrics.taskCompletionRate & "%",
                    color: if(
                      local!systemMetrics.taskCompletionRate >= 80,
                      "POSITIVE",
                      if(
                        local!systemMetrics.taskCompletionRate >= 60,
                        "ACCENT",
                        "NEGATIVE"
                      )
                    )
                  ),
                  a!stampField(
                    labelPosition: "ABOVE",
                    label: "Active Users",
                    text: local!systemMetrics.activeUsers,
                    backgroundColor: "ACCENT",
                    contentColor: "STANDARD",
                    size: "MEDIUM"
                  )
                }
              )
            },
            width: "MEDIUM"
          )
        }
      )
    },
    
    /* Refresh Data on Load */
    refreshAfter: a!refreshVariable(
      value: local!refreshCounter,
      refreshOnVarChange: true,
      refreshOnlyAfterSave: false
    )
  )
)