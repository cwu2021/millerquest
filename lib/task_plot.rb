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

def show_prologue
  prologueitems = YAML::load(File.open("#{$datadir}/prologue.yml"))
  prologueitems.each do |i|
    i.complete
  end
end

