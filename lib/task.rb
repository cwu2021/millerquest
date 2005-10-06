# The generic classes that represent various tasks that the player does.
# These things track the player's progress in the task, and can be saved.


# How long should we wait between updates? (in seconds)
GAME_SPEED = 0.2

# The generic class that describes various tasks found in the game.
class Task
  # The title of the current task.
  attr :title
  # The portion of the progress that is already done. Between 0 and length_of_progress (or
  # >0 on general terms if length_of_progress is nil.)
  attr_reader :current_progress
  # How long the progress really is.
  # If the task has indeterminable length, the value is nil.
  attr_reader :length_of_progress
  # Should progress stuff be displayed on screen
  attr :quiet

  public
  def initialize
    @started = false
    @complete = false
    @start_printed = false
    @title = ""
    @length_of_progress = 0
    @current_progress = 0
    @saveable = true
  end

  # This method should be called after the task has been deserialized.
  def defrost
    @start_printed = false
  end

  # Is the current task complete?
  public
  def complete?
    if not @length_of_progress.nil?
      @complete or @current_progress >= @length_of_progress
    else
      @complete
    end
  end

  private
    # Start of the progress.
    def start
      @started = true
      @current_progress = 0
      print_start
    end
    # Print the starting stuff
    def print_start
      return if @quiet
      titlebar(@title,'>')
      print "["
      $stdout.flush
    end
    # Prints the partial progress (dots) up to the current moment
    def print_partial_progress
      return if @quiet
      for i in 0..@current_progress
        print (i == 0 ? "" : ".")
        $stdout.flush
      end
    end
    def print_end
      return if @quiet
      puts "]"
    end

  # Go forward in the task. will return false if the task fails.
  public
  def advance_task
    @current_progress = @current_progress + 1
    unless @quiet then
      print "#"
      $stdout.flush
      sleep GAME_SPEED
    end
  end
  
  # This will run the task from start to end, and report progress. Will return
  # true or false depending on what happened.
  public
  def complete
    start
    if @current_progress != 0
      print_partial_progress
    end
    while advance_task and not complete? do
    end
    print_end
  end
  
end
