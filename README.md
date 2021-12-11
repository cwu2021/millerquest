# Miller's Quest

<i>Miller's quest</i> developer documentation

The most important parts of the whole mess are as follows:

* The main loop, which resides in millerquest.rb.

* The adventuring, which is defined pretty well in the Adventure module
  (lib/adventure.rb). This defines most of the day-to-day life of our
  intrepid adventurer. This is tied pretty well to the task system
  described below.

* Equipment system (lib/equipment.rb) and the DamageType and Material
  systems (lib/typesandprops.rb).
* Task system (lib/task.rb) - Tasks are things that the player does.
  These are subclassed from the main Task class.
  For example, you can watch the plot unfold (PlotTask), or kill a
  monster (FightTask). They're then done by calling the Task#complete
  method of the object. Currently available tasks:
  * PlotTask - for simple procedures that can't really be messed up.
    good for advancing the plot.
  * TravelTask - Moves the player between the town and the killing fields.
  * FightTask - Combat the baddies!
  * MerchantSellTask - Sells stuff to the merchant at the town.
