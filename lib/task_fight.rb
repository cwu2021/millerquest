# $Id$
# The combat system.

# This thing will fight a nasty monster.
class FightTask < Task
  # The monster we're fighting currently.
  attr_accessor :monster
  private
    # This will make the fight happen. This method will directly update the victim's
    # HP, and will return one of the following:
    # * If missed: :miss
    # * If hit: :hit, :fatal (fatal hit), :critical (non-fatal critical),
    #   :critical_fatal
    def resolve_attack(attacker,defender)
      awb = attacker.weapon.total_bonus
      astr = attacker.strength
      dwb = defender.weapon.total_bonus
      adex = attacker.dexterity
      ddex = defender.dexterity

      # Hit? Dexterity-based comparison and some freak luck too.
      if ((adex/ddex) * rand(20) < 15)
        # Should miss.
        if rand(20) <= 1
          # Beginner's luck...
          miss = false
        else
          # The dice have no mercy.
          miss = true
        end
      end
      if miss == true
        return :miss
      end

      # Okay, we hit. For how much?
      dmg = rand(astr) + awb

      # critical hit?
      critical = false
      if rand(20) >= 19-(awb/2)
        critical = true
      end
      
      defender.hp = defender.hp - (critical ? dmg*2 : dmg)
      if defender.hp <= 0
        return (critical ? :critical_fatal : :fatal)
      else
        return (critical ? :critical : :hit)
      end      
    end
    
    # Spices up the combat by making the combatant scream obscenities at the
    # enemy. Noticeably censored for stylistic reasons. Well, I didn't
    # actually censor this, just never wrote bad stuff.
    # FIXME: Should load all of the screams from from YAML
    def shout_obscenities
      ccnor = Display.clear_attributes
      ccmsg = Display.color_codes[:foreground][:black]
      ccwpn = Display.color_codes[:foreground][:cyan]
      ccshoutgood = Display.bold + Display.color_codes[:foreground][:green]
      ccshoutbad = Display.color_codes[:foreground][:red]
      if @attack_turn == :player
        # Stuff the player screams.
        # TODO: Add a "fighting style" option that allows for different fighting sounds.
        puts "#{ccmsg}You attack the monster with your #{ccwpn}#{$player.weapon}#{ccmsg}.#{ccnor}"
        case rand(10)
          when 0 then
            puts "#{ccshoutgood}Hi-yah!#{ccnor}"
          when 1 then
            puts "#{ccshoutgood}Slice and dice!#{ccnor}"
          when 2 then
            puts "#{ccshoutgood}Diiiieeeeee!#{ccnor}"
          when 3 then
            puts "#{ccshoutgood}For the Kingdom!#{ccnor}"
        end
      elsif @attack_turn == :monster
        # Stuff the monster screams.
        # TODO: Add some flavor by adding some monster-specific screams.
        puts "The monster tries to kill you."
        case rand(5)
          when 0 then
            puts "#{ccshoutbad}GRRRRRAAAGH!#{ccnor}"
          when 1 then
            puts "#{ccshoutbad}DIE!#{ccnor}"
        end      
      end
      $stdout.flush
    end

    # Prints out a message on a successful hit.
    # FIXME: Should load all of the hit messages from from YAML
    def hit_message(critical)
      if @attack_turn == :player
        case rand(2)
          when 0 then
            msg = "<slash!>"
          when 1 then
            msg = "<slice!>"
        end
      else
        case rand(2)
          when 0 then
            msg = "<ouch!>"
          when 1 then
            msg = "<argh!>"
        end
      end
      # FIXME: more creative critical hit messages
      if critical
        msg.upcase!
      end
      puts "#{Display.color_codes[:foreground][:red]}#{msg}#{Display.clear_attributes}"
    end

    # Prints out some random stuff on death.
    # FIXME: Should load all of the screams from from YAML
    def death_scream
      print Display.bold + Display.color_codes[:foreground][:red]
      if @attack_turn == :player
        # Stuff the enemy screams when player kills them
        # TODO: Add more stuff
        case rand(4)
          when 0 then
            print "GRARGRROAG"
          when 1 then
            print "Grrr"
          when 2 then
            print "Arrrg"
          when 3 then
            print "<whimper>"
        end
        print Display.clear_attributes + Display.color_codes[:foreground][:red]
        puts " sayeth the monster..." + Display.clear_attributes
      elsif @attack_turn == :monster
        # Stuff the player screams when enemy kills them
        # TODO: More clever death-screams?
        print Display.bold + Display.color_codes[:foreground][:red]
        case rand(6)
          when 0..4 then
            print "ARRRRGH!!!!!!!"
          when 5 then
            print '"Me dead? That is unpossible!"'
        end      
        print Display.clear_attributes + Display.color_codes[:foreground][:red]
        puts " sayeth #{$player.name}..." + Display.clear_attributes
      end
      $stdout.flush
    end
    
    # Prints out some shady dots to make an appearance more is going on than
    # it really is.
    def shady_dots
      4.times do
        @spinner.spin
        print @spinner.current_value
        $stdout.flush
        sleep GAME_SPEED
        print Display.erase_line
        $stdout.flush
      end
    end
    
  public
    def initialize
      # General administrativia
      super()
      @length_of_progress = nil
      
      # A nasty monster, is it not?
      m = $monsters.random_key
      @monster = $monsters[m].dup
      @monster.prepare_for_battle

      # Tell the world that we're killing that thing!
      @title = "Killing #{m}"

      # Whose turn it is to attack?
      case rand(2)
        when 0 then
          @attack_turn = :player
        when 1 then
          @attack_turn = :monster
      end
    end

    # Plays one round of combat. Will return true or false depending if the last hit
    # was fatal.
    def advance_task
      shout_obscenities

      super() # Increment counter and shit
      
      if @attack_turn == :player
        r = resolve_attack($player,@monster)
      elsif @attack_turn == :monster
        r = resolve_attack(@monster,$player)
      end
      result = true
      case r
        when :miss then
          shady_dots
        when :hit then
          hit_message(false)
          $stdout.flush
          shady_dots 
        when :critical then
          hit_message(true)
          $stdout.flush
          shady_dots
        when :fatal then
          death_scream
          @complete = true
          result = false
        when :critical_fatal then
          puts "<WHA-BOOM! What a hit!>"
          death_scream
          @complete = true
          result = false
      end
      $stdout.flush
      if not @complete
        if @attack_turn == :player
          @attack_turn = :monster
        else
          @attack_turn = :player
        end
      end
      return result
    end
    
    # Returns who won - true if player, false if monster.
    def player_won?
      if @attack_turn == :player
        return true
      end
      return false
    end
end

class HealingTask < PlotTask
  def initialize
    super("Visiting the healing springs",10)
  end
  def finished
    $player.heal
    puts "Hitpoints restored to #{$player.hp}/#{$player.maxhp}"
  end
end
