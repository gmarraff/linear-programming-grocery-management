require_relative '../data'
require_relative '../exceptions/set_empty'
module PLI
  module Spesa
    class Data < ::PLI::Data
      # INSIEMI
      attr_accessor :plates, :ingredients, :packages
      attr_accessor :meals, :plates_in_meals

      # PARAMETRI
      attr_accessor :upper_bound, :prices, :stock, :packages_content, :recipes
      attr_accessor :meals_variety, :needed_meals
      attr_accessor :min_plates, :max_plates, :min_ingredients

      def initialize(_plates, _ingredients, _packages)
        self.plates = _plates
        self.ingredients =_ingredients
        self.packages = _packages
      end
      def is_valid?
        return false if @upper_bound.nil? or @upper_bound < 0
        [
            @plates, @ingredients, @packages, @prices, @packages_content,
            @recipes, @meals_variety, @needed_meals, @max_plates
        ].each do |attr|
          return false if attr.nil? or attr.empty?
        end
        true
      end

      ##Example object
      #{
      #  pranzo: ['pasta al ragu', 'pasta coi broccoli'],
      #  cena: ['cotoletta']
      # }
      def plates=(set)
        raise PLI::Exceptions::SetEmpty.new('plates') if set.empty?
        set.each {|meals, plates| plates.collect!{|plate| sanitize_string(plate.to_s)}}
        @plates_in_meals = set.collect{|k,v| [sanitize_string(k.to_s), v]}.to_h #Trasforma in stringhe le chiavi
        @meals = set.keys.collect{|meal| sanitize_string(meal.to_s)}
        @plates = []
        set.each{|meals, plates| @plates += plates}
      rescue NoMethodError, TypeError
        raise PLI::Exceptions::SetNotValid.new('plates')
      end
      def ingredients=(_ingredients)
        @ingredients = _ingredients.collect{|ingredient| sanitize_string(ingredient)}
        raise PLI::Exceptions::SetEmpty.new('ingredients') if _ingredients.empty?
      rescue NoMethodError
        raise PLI::Exceptions::SetNotValid.new('ingredients')
      end
      def packages=(_packages)
        @packages = _packages.collect{|package| sanitize_string(package)}
        raise PLI::Exceptions::SetEmpty.new('packages') if _packages.empty?
      rescue NoMethodError
        raise PLI::Exceptions::SetNotValid.new('ingredients')
      end
      def meals=(value)
        @meals = []
      end
      def upper_bound=(value)
        if value.is_a?Integer and value > 0
          @upper_bound = value
        else
          raise ::TypeError.new('Must be a positive integer!')
        end
      end
      #{'pancetta mondadori' : 22.5}
      def prices=(_prices)
        @prices = mono_dimensional_param(@packages, _prices, 'packages')
      end
      #{'confezione_pancetta' : 2}
      def stock=(_stock)
        @stock = mono_dimensional_param(@ingredients, _stock, 'packages')
      end
      def meals_variety=(_variety)
        @meals_variety = mono_dimensional_param(@meals, _variety, 'meals')
      end
      def needed_meals=(_need)
        @needed_meals = mono_dimensional_param(@meals, _need, 'meals')
      end
      def min_plates=(_values)
        @min_plates = mono_dimensional_param(@plates, _values, 'plates')
      end
      def max_plates=(_values)
        @max_plates = mono_dimensional_param(@plates, _values, 'plates')
      end
      def min_ingredients=(_values)
        @min_ingredients = mono_dimensional_param(@ingredients, _values, 'ingredients')
      end
      #{'pancetta_mondadori': {'confezione_pancetta': 2}}
      def packages_content=(_contents)
        @packages_content = bi_dimensional_param(@packages, @ingredients, _contents, 'packages', 'ingredients')
      end
      #{'carbonara': {'confezione_pancetta': 1, 'uova: 1'}}
      def recipes=(_recipes)
        @recipes = bi_dimensional_param(@plates, @ingredients, _recipes, 'plates', 'ingredients')
      end
    end
  end
end
