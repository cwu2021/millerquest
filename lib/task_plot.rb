# $Id$
# The plot-related tasks are defined here.

# A general plot task; always completeable, and does nothing particularly
# dangerous. These are used to advance the plot and such.
class PlotTask < Task
  def initialize(description,length)
    super()
    @title = description
    @length_of_progress = length
    @saveable = false
  end
  def advance_task
    super()
    return true
  end
end

