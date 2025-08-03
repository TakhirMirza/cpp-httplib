/*
 * Interface: Task List
 * Description: Task management interface with filtering, sorting, and actions
 * Created: Template
 */

a!localVariables(
  /* Local Variables */
  local!tasks: {},
  local!filteredTasks: {},
  local!selectedTasks: {},
  local!filterStatus: "All",
  local!filterPriority: "All",
  local!filterAssignee: "All",
  local!searchText: "",
  local!sortField: "createdDate",
  local!sortAscending: false,
  local!showCreateDialog: false,
  local!newTask: type!Task(),
  
  /* Interface Layout */
  a!headerContentLayout(
    header: a!cardLayout(
      contents: {
        a!richTextDisplayField(
          value: a!richTextItem(
            text: "Task Management",
            size: "LARGE",
            style: "STRONG"
          )
        )
      },
      style: "ACCENT",
      marginBelow: "STANDARD"
    ),
    contents: {
      /* Filter and Search Section */
      a!cardLayout(
        contents: {
          a!columnsLayout(
            columns: {
              a!columnLayout(
                contents: {
                  a!textField(
                    label: "Search Tasks",
                    placeholder: "Search by title or description...",
                    value: local!searchText,
                    saveInto: local!searchText,
                    refreshAfter: "KEYPRESS"
                  )
                },
                width: "WIDE"
              ),
              a!columnLayout(
                contents: {
                  a!dropdownField(
                    label: "Status",
                    choiceLabels: {"All", "New", "In Progress", "Completed", "Cancelled"},
                    choiceValues: {"All", "New", "In Progress", "Completed", "Cancelled"},
                    value: local!filterStatus,
                    saveInto: local!filterStatus
                  )
                },
                width: "NARROW"
              ),
              a!columnLayout(
                contents: {
                  a!dropdownField(
                    label: "Priority",
                    choiceLabels: {"All", "Low", "Medium", "High", "Critical"},
                    choiceValues: {"All", "Low", "Medium", "High", "Critical"},
                    value: local!filterPriority,
                    saveInto: local!filterPriority
                  )
                },
                width: "NARROW"
              ),
              a!columnLayout(
                contents: {
                  a!buttonWidget(
                    label: "Create Task",
                    icon: "plus",
                    style: "PRIMARY",
                    saveInto: a!save(local!showCreateDialog, true)
                  )
                },
                width: "NARROW"
              )
            }
          )
        },
        marginBelow: "STANDARD"
      ),
      
      /* Task Grid */
      a!cardLayout(
        contents: {
          a!gridField(
            label: "Tasks (" & length(local!filteredTasks) & ")",
            data: local!filteredTasks,
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
                ),
                width: "WIDE"
              ),
              a!gridColumn(
                label: "Status",
                sortField: "status",
                value: a!tagField(
                  tags: a!tagItem(
                    text: fv!row.status,
                    backgroundColor: choose(
                      wherecontains(fv!row.status, {"New", "In Progress", "Completed", "Cancelled"}),
                      "SECONDARY",
                      "ACCENT",
                      "POSITIVE",
                      "NEGATIVE"
                    )
                  )
                ),
                width: "NARROW"
              ),
              a!gridColumn(
                label: "Priority",
                sortField: "priority",
                value: a!tagField(
                  tags: a!tagItem(
                    text: fv!row.priority,
                    backgroundColor: choose(
                      wherecontains(fv!row.priority, {"Low", "Medium", "High", "Critical"}),
                      "SECONDARY",
                      "ACCENT",
                      "NEGATIVE",
                      "NEGATIVE"
                    )
                  )
                ),
                width: "NARROW"
              ),
              a!gridColumn(
                label: "Assigned To",
                sortField: "assignedTo.firstName",
                value: if(
                  isnull(fv!row.assignedTo),
                  "Unassigned",
                  fv!row.assignedTo.firstName & " " & fv!row.assignedTo.lastName
                ),
                width: "MEDIUM"
              ),
              a!gridColumn(
                label: "Due Date",
                sortField: "dueDate",
                value: if(
                  isnull(fv!row.dueDate),
                  "No due date",
                  text(fv!row.dueDate, "MM/DD/YYYY")
                ),
                width: "NARROW"
              ),
              a!gridColumn(
                label: "Actions",
                value: a!buttonArrayLayout(
                  buttons: {
                    a!buttonWidget(
                      label: "Edit",
                      icon: "edit",
                      size: "SMALL",
                      style: "OUTLINE",
                      saveInto: {
                        /* Open edit dialog */
                      }
                    ),
                    a!buttonWidget(
                      label: "Complete",
                      icon: "check",
                      size: "SMALL",
                      style: "OUTLINE",
                      showWhen: fv!row.status <> "Completed",
                      saveInto: {
                        /* Mark task as completed */
                        a!save(
                          fv!row.status,
                          "Completed"
                        ),
                        a!save(
                          fv!row.completedDate,
                          now()
                        )
                      }
                    )
                  },
                  align: "START"
                ),
                width: "NARROW"
              )
            },
            selectable: true,
            selectionValue: local!selectedTasks,
            selectionSaveInto: local!selectedTasks,
            pageSize: 20,
            showWhen: length(local!filteredTasks) > 0,
            emptyGridMessage: "No tasks found matching your criteria",
            sorting: a!sortInfo(
              field: local!sortField,
              ascending: local!sortAscending
            )
          ),
          
          /* Bulk Actions */
          a!buttonArrayLayout(
            buttons: {
              a!buttonWidget(
                label: "Bulk Complete",
                icon: "check-circle",
                style: "SECONDARY",
                showWhen: length(local!selectedTasks) > 0,
                saveInto: {
                  /* Bulk complete selected tasks */
                }
              ),
              a!buttonWidget(
                label: "Bulk Delete",
                icon: "trash",
                style: "DESTRUCTIVE",
                showWhen: length(local!selectedTasks) > 0,
                saveInto: {
                  /* Bulk delete selected tasks */
                }
              )
            },
            align: "START",
            marginAbove: "STANDARD",
            showWhen: length(local!selectedTasks) > 0
          )
        }
      )
    },
    
    /* Create Task Dialog */
    showWhen: local!showCreateDialog,
    overlay: a!dialogBox(
      label: "Create New Task",
      contents: {
        a!textField(
          label: "Title",
          value: local!newTask.title,
          saveInto: local!newTask.title,
          required: true
        ),
        a!paragraphField(
          label: "Description",
          value: local!newTask.description,
          saveInto: local!newTask.description
        ),
        a!dropdownField(
          label: "Priority",
          choiceLabels: {"Low", "Medium", "High", "Critical"},
          choiceValues: {"Low", "Medium", "High", "Critical"},
          value: local!newTask.priority,
          saveInto: local!newTask.priority,
          required: true
        ),
        a!dateField(
          label: "Due Date",
          value: local!newTask.dueDate,
          saveInto: local!newTask.dueDate
        )
      },
      buttons: {
        a!buttonWidget(
          label: "Create",
          style: "PRIMARY",
          saveInto: {
            /* Save new task */
            a!save(local!newTask.createdDate, now()),
            a!save(local!newTask.createdBy, loggedInUser()),
            a!save(local!newTask.status, "New"),
            /* Add to tasks list */
            a!save(local!tasks, append(local!tasks, local!newTask)),
            /* Reset form */
            a!save(local!newTask, type!Task()),
            a!save(local!showCreateDialog, false)
          }
        ),
        a!buttonWidget(
          label: "Cancel",
          style: "OUTLINE",
          saveInto: {
            a!save(local!newTask, type!Task()),
            a!save(local!showCreateDialog, false)
          }
        )
      }
    )
  )
)