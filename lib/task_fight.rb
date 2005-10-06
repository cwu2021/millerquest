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
      if @attack_turn == :player
        # Stuff the player screams.
        # TODO: Add a "fighting style" option that allows for different fighting sounds.
        case rand(10)
          when 0 then
            print " Hi-yah! "
          when 1 then
            print " Slice and dice! "
          when 2 then
            print " Diiiieeeeee! "
          when 3 then
            print " For the Kingdom! "
        end
      elsif @attack_turn == :monster
        # Stuff the monster screams.
        # TODO: Add some flavor by adding some monster-specific screams.
        case rand(5)
          when 0 then
            print " GRRRRRAAAGH! "
          when 1 then
            print " DIE! "
        end      
      end
      $stdout.flush
    end

    # Prints out some random stuff on death.
    # FIXME: Should load all of the screams from from YAML
    def death_scream
      print " "
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
        print " sayeth the monster..."
      elsif @attack_turn == :monster
        # Stuff the player screams when enemy kills them
        # TODO: More clever death-screams?
        case rand(6)
          when 0...4 then
            print "ARRRRGH!!!!!!!"
          when 5 then
            print '"Me dead? That is unpossible!"'
        end      
        print " sayeth #{$player.name}..."
      end
      $stdout.flush
    end
    
    # Prints out some shady dots to make an appearance more is going on than
    # it really is.
    def shady_dots
      4.times do
        print "#"
        $stdout.flush
        sleep GAME_SPEED
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
      $stdout.flush
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
          print " <slash!> "
          $stdout.flush
          shady_dots 
        when :critical then
          print " <CRITICAL HIT!> "
          $stdout.flush
          shady_dots
        when :fatal then
          death_scream
          @complete = true
          result = false
        when :critical_fatal then
          print " <WHA-BOOM! What a hit!> "
          death_scream
          @complete = true
          result = false
      end
      $stdout.flush
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
