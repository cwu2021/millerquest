# How long should we wait between updates? (in seconds)
# $GAME_SPEED = 0.8
$GAME_SPEED = 0.4

# Display using stdlib curses
class Display
  attr_accessor :scr
  attr_accessor :csy, :cslines            ## Center stage
  attr_accessor :tiy                      ## Title area
  attr_accessor :aly1, :alpx, :alpy       ## Attack area
  attr_accessor :spinner
  
  def Display.set_up
    @spinner = Spinner.new
    @scr = Curses.init_screen
    Curses.curs_set(0)
    Curses.stdscr.nodelay = 1
    Curses::noecho
    @csy = 4
    @cslines = 13
    @tiy = 18
    @aly = 20
    @alpx = 5
    @almx = 40
  end
  
  def Display.clear_line(num)
    @scr.setpos(num,0)
    @scr.clrtoeol
  end

  def Display.clear_title_area
    clear_line(@tiy+0)
    clear_line(@tiy+1)
  end

  def Display.clear_attack_area
    clear_line(@aly+0)
    clear_line(@aly+1)
    clear_line(@aly+2)
  end

  def Display.clear_center_stage
    for lno in 0..(@cslines-1) do
      clear_line(@csy+lno)
    end
  end

  def Display.center_stage_drawing(fn)
    y = @csy
    clear_center_stage
    f = File.open("#{$datadir}/#{fn}.txt")
    drawing = f.readlines.join("")
    f.close
    drawing.each do |line|
      @scr.setpos(y,0)
      @scr.addstr(line)
      y = y + 1
    end
  end

  def Display.begin_fight(msg)
    center_stage_drawing("fight1")
    clear_title_area
    clear_attack_area
    @scr.setpos(@tiy,@alpx)
    @scr.addstr(msg)
    check_events(2*$GAME_SPEED)
  end

  def Display.begin_fight_round(player_turn)
    clear_attack_area
    if (player_turn)
      @scr.setpos(@aly,@alpx)
      @scr.addstr("You attack!")
    else
      @scr.setpos(@aly,@almx)
      @scr.addstr("It attacks!")
    end
    @scr.refresh
  end

  def Display.miss_message(player_turn)
    if (player_turn)
      @scr.setpos(@aly+1,@alpx)
      @scr.addstr("You miss")
    else
      @scr.setpos(@aly+1,@almx)
      @scr.addstr("It misses")
    end
  end

  def Display.hit_message(player_turn,dmg)
    if (player_turn)
      @scr.setpos(@aly+1,@alpx)
      @scr.addstr(sprintf("You hit for %d points of damage",dmg))
    else
      @scr.setpos(@aly+1,@almx)
      @scr.addstr(sprintf("It hits for %d points of damage",dmg))
    end
  end

  def Display.crit_hit_message(player_turn,dmg)
    if (player_turn)
      @scr.setpos(@aly+1,@alpx)
      @scr.addstr(sprintf("Critical hit! %d points of damage",dmg))
    else
      @scr.setpos(@aly+1,@almx)
      @scr.addstr(sprintf("Critical hit!  %d points of damage",dmg))
    end
  end

  def Display.die_message(player_turn,dmg)
    if (player_turn)
      @scr.setpos(@aly+2,@alpx)
      @scr.addstr("You kill your foe!")
    else
      @scr.setpos(@aly+2,@almx)
      @scr.addstr("You die")
    end
  end

  def Display.attack_message(player_turn, r)
    if (player_turn)
      shady_dots(@aly+1,@alpx)
    else
      shady_dots(@aly+1,@almx)
    end
    show_stats
    case r[0]
    when :miss then
      miss_message(player_turn)
    when :hit then
      hit_message(player_turn,r[1])
    when :critical then
      crit_hit_message(player_turn,r[1])
    when :fatal then
      hit_message(player_turn,r[1])
      die_message(player_turn,r[1])
    when :critical_fatal then
      crit_hit_message(player_turn,r[1])
      die_message(player_turn,r[1])
    end
    @scr.refresh
    check_events ($GAME_SPEED)
  end

  def Display.shady_dots(y,x)
    4.times do
      @spinner.spin
      @scr.setpos(y,x)
      @scr.addstr(@spinner.current_value)
      @scr.refresh
      check_events ($GAME_SPEED/4)
    end
    @scr.setpos(y,x)
    @scr.addstr(" ");
    @scr.refresh
  end

  def Display.hashes(num)
    @scr.addstr("[")
    num.times do
      @scr.addstr("#")
      check_events($GAME_SPEED/2)
    end
    @scr.addstr("]")
    check_events($GAME_SPEED)
  end

  def Display.healing_springs
    center_stage_drawing("heal1")
    clear_attack_area
    @scr.setpos(@aly,5)
    @scr.addstr("Visiting the healing springs")
    @scr.setpos(@aly+1,5)
    hashes(10)
    show_stats
  end

  def Display.quest(msg1,msg2)
    center_stage_drawing("quest1")
    clear_title_area
    clear_attack_area
    @scr.setpos(@aly,5)
    @scr.addstr(msg1)
    check_events ($GAME_SPEED)
    @scr.setpos(@aly+1,5)
    @scr.addstr(msg2)
    check_events ($GAME_SPEED*3)
  end

  def Display.blink_center_stage(msg)
    clear_center_stage
    @scr.setpos(@csy+4,35)
    @scr.addstr(msg)
    check_events ($GAME_SPEED/2)
    @scr.setpos(@csy+4,35)
    @scr.addstr("       ")
    check_events ($GAME_SPEED/2)
    @scr.setpos(@csy+4,35)
    @scr.addstr(msg)
    check_events ($GAME_SPEED)
  end

  def Display.victory
    clear_title_area
    blink_center_stage("Victory")
  end

  def Display.defeat
    clear_title_area
    blink_center_stage("Defeat")
  end

  def Display.loot(gotxp,drops)
    clear_title_area
    clear_attack_area
    @scr.setpos(@aly,@alpx)
    @scr.addstr("Got #{gotxp} exp. #{$player.to_next_level} to next level.")
    check_events ($GAME_SPEED)
    @scr.setpos(@aly+1,@alpx)
    @scr.addstr("Picked up #{drops}")
    check_events ($GAME_SPEED)
    @scr.setpos(@aly+2,@alpx)
    @scr.addstr("Currently carrying #{$player.loot_weight}/#{$player.carrying_capacity}")
    check_events (2*$GAME_SPEED)
    show_stats
  end

  def Display.haggle(title,newgold)
    center_stage_drawing("town1")
    clear_attack_area
    @scr.setpos(@aly,@alpx)
    @scr.addstr(title)
    @scr.setpos(@aly+1,5)
    hashes(5+rand(9))
    @scr.setpos(@aly+2,5)
    @scr.addstr("Got #{newgold} gp for that")
    show_stats
    check_events(2*$GAME_SPEED)
  end

  def Display.sell(msg,resale)
    clear_attack_area
    @scr.setpos(@aly,@alpx)
    @scr.addstr(msg)
    @scr.setpos(@aly+1,5)
    hashes(2+rand(3))
    @scr.setpos(@aly+2,5)
    @scr.addstr("Got #{resale} gp for it!")
    show_stats
    check_events(2*$GAME_SPEED)
  end

  def Display.buy(msg,cost)
    clear_attack_area
    @scr.setpos(@aly,@alpx)
    @scr.addstr(msg)
    @scr.setpos(@aly+1,5)
    hashes(2+rand(3))
    @scr.setpos(@aly+2,5)
    @scr.addstr("What a deal! It was only #{cost} gp!")
    show_stats
    check_events(2*$GAME_SPEED)
  end

  def Display.travel_to_town
    center_stage_drawing("totown1")
    clear_title_area
    clear_attack_area
    @scr.setpos(@aly,@alpx)
    @scr.addstr("Dragging monster carcasses to the town")
    @scr.setpos(@aly+1,@alpx)
    hashes(20)
  end

  def Display.gain_level(msg,spell_msg)
    clear_title_area
    clear_attack_area
    @scr.setpos(@tiy,@alpx)
    @scr.addstr("You gained a level!")
    check_events($GAME_SPEED)
    @scr.setpos(@tiy+1,@alpx)
    @scr.addstr("Max HP increased to #{$player.maxhp}")
    check_events($GAME_SPEED)
    @scr.setpos(@aly,@alpx)
    @scr.addstr(msg)
    check_events($GAME_SPEED)
    @scr.setpos(@aly+1,@alpx)
    @scr.addstr(spell_msg)
    check_events(2*$GAME_SPEED)
  end

  def Display.travel_to_killing_fields
    center_stage_drawing("tokilling1")
    clear_title_area
    clear_attack_area
    case rand(3)
    when 0 then 
      title = "Heading to the nearby bushes"
      length = 10
    when 1 then
      title = "The bloody fields do call you!"
      length = 20
    when 2 then
      title = "Taking a few steps out of town to find monsters"
      length = 5
    end
    @scr.setpos(@aly,@alpx)
    @scr.addstr(title)
    @scr.setpos(@aly+1,@alpx)
    hashes(length)
  end

  def Display.show_stats
    @scr.setpos(1,2)
    @scr.addstr(sprintf("Str:%3d   ",$player.strength))
    @scr.addstr(sprintf("Dex:%3d   ",$player.dexterity))
    @scr.addstr(sprintf("Gut:%3d   ",$player.guts))
    @scr.addstr(sprintf("Int:%3d   ",$player.intelligence))
    @scr.addstr(sprintf("Cha:%3d   ",$player.charm))
    @scr.addstr(sprintf("LVL:%8d   ",$player.level))
    @scr.setpos(2,2)
    @scr.addstr(sprintf("HP:%4d/%4d   ",$player.hp,$player.maxhp))
    @scr.addstr(sprintf("Gold:%6d   ",$player.gold))
    @scr.addstr(sprintf("Carry:%6d/%6d   ",$player.loot_weight,
                        $player.carrying_capacity))
    @scr.addstr(sprintf("XP:%8d/%8d" ,$player.exp,
                        $player.exp + $player.to_next_level))
    @scr.refresh
  end

  ## Returns if there is an event before the timeout
  def Display.check_events (timeout)
    ticks = timeout / 0.1
    while true
      ## No way to get Curses::ERR in ruby?  Instead, test if 
      ## value is <= 255.
      if ((foo = @scr.getch) <= 255)
        if (foo == ?q)
          $game_over = 1
          return
        end
      end
      if (ticks > 0)
        ticks -= 1
        sleep 0.1
      else
        return
      end
    end
  end

  def shutdown
    Curses.close_screen
  end
end
