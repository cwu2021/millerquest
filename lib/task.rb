# The generic classes that represent various tasks that the player does.
# These things track the player's progress in the task, and can be saved.
#
# ============================================================================
# Miller's Quest!, a role-playing game simulator.
# Copyright (C) 2005  Urpo 'WWWWolf' Lankinen.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# ============================================================================



# Implements the "spinning baton" progress meter.
class Spinner
  SPINNER_CHARACTERS = %w{ | / - \\ | / - \\ }
  def initialize
    # These should be static...
    @state = 0
  end
  # Increments the animation and returns the current character.
  def spin
    @state = (@state + 1) % SPINNER_CHARACTERS.length
    return current_value
  end
  # returns the currect character.
  def current_value
    return SPINNER_CHARACTERS[@state]
  end
end

# The generic class that describes various tasks found in the game.
# Subclass can also define method "finished" if it wants something done
# when the task is done.
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
  # Will be spun when progressing.
  attr_reader :spinner

  public
  def initialize
    @started = false
    @complete = false
    @start_printed = false
    @title = ""
    @length_of_progress = 0
    @current_progress = 0
    @saveable = true
    @spinner = Spinner.new
  end

  # This method should be called after the task has been deserialized.
  # (should, when it isn't right now. too lazy. only controls printing anyway)
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
    unless @spinner.nil?
      @spinner.spin
    end
    @current_progress = @current_progress + 1
    unless @quiet then
      unless @length_of_progress.nil?
        print "#"
        $stdout.flush
      end
      sleep $GAME_SPEED
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
    if self.respond_to? :finished
      self.finished
    end
  end
  
end

