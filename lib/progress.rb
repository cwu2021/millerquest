def progress(title,length)
  titlebar(title,'>')
  start_from = $player.current_progress
  if start_from.nil?
    start_from = 0
  end
  print "["
  $stdout.flush
  for i in 0..start_from
    print (i == 0 ? "" : ".")
    $stdout.flush
  end
  for i in (start_from+1)..(length-1)
    $player.current_progress = i
    print "#"
    $stdout.flush
    sleep 0.2
  end
  puts "]"
  $player.current_progress = 0
end

