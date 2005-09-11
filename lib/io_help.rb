def print_line
  puts "-" * 70
end

def printlist(list)
  puts
  i = 0
  list.each do |r|
    puts "#{i+1})\t#{r}"
    i = i + 1
  end
  puts
end

def get_option(list,prompt,errormsg)
  choice = nil
  while choice == nil
    printlist(list)
    print prompt
    c = gets.chomp.to_i - 1
    if c < 0 or c > list.length
      puts errormsg
      choice = nil
    else
      choice = list[c]
    end
  end
  return choice
end


def titlebar(title,letter)
  xlength = 70-title.length-2-(letter.length)*3
  if xlength > 0
    restbar = letter*xlength
  else
    restbar = ''
  end
  puts "#{letter*3} #{title} #{restbar}"
end



def titlescreen
  puts $title_screen
end
