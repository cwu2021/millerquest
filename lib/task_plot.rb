# $Id: task_plot.rb 25 2005-10-26 22:14:56Z wwwwolf $
#
# The plot-related tasks are defined here.
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

