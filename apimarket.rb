#other changes i would consider making: a way to structure the code so that only age
#restricted items are checked for age, seems inefficient to check items that anyone 
#of any age can buy 

# you can buy just a few things at this apimarket
require 'highline'


class Apimarket
  
  NoSale= Class.new(StandardError)

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type) 
    itm = case itm_type
          when :beer
            Item::Beer.new(@logfile, @prompter)
          when :whiskey
            Item::Whiskey.new(@logfile, @prompter)
          when :cigarettes
            Item::Cigarettes.new(@logfile, @prompter)
          when :cola
            Item::Cola.new(@logfile, @prompter)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile, @prompter)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end
    itm.rstrctns.each { |r| itm.try_purchase(r.ck) }
    itm.log_sale
  end
end

class HighlinePrompter
  def get_age
    # prompts for user's age, reads it in
    HighLine.new.ask('Age? ', Integer) 
  end
end


module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def initialize(p)
      @prompter = p
    end

    def ck
      @prompter.get_age >= DRINKING_AGE ? true : false
    end
  end

  class SmokingAge
    def initialize(p)
      @prompter = p
    end

    def ck
      @prompter.get_age >= SMOKING_AGE ? true : false
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def ck
      # 0 is Sunday
      Time.now.wday != 0      
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end
#this section I am unsure of, it seems that the nam object here is converted to a string
#and then several lines later converted to a symbol, only to be converted back to a string
#in the log_sale method above--> not sure if that is part of the test or if it's some 
#sort of convention or something i am unaware of, but seemed weird enough to me that i 
#thought i would point it out 
  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(success)
    success ? true : (raise Apimarket::NoSale)
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Cola < Item
    def rstrctns
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def rstrctns
      []
    end
  end
end
