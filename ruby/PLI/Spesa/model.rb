require_relative '../Spesa/data'
require_relative '../Spesa/solution'
require_relative '../exceptions/data_not_valid'
require 'forwardable'
require 'ruby-cbc'
require 'logger'
module PLI
  module Spesa
    class Model
      def initialize(data)
        change_data(data)
      end

      def change_data(data)
        raise PLI::Exceptions::DataNotValid unless data.is_a?PLI::Spesa::Data and data.is_valid?
        @cbc = ::Cbc::Model.new
        @data = data
        set_variables
        set_target
        subject_to
        @problem = nil
      end

      def lp_model
        @cbc.to_s
      end
      def solve
        @problem = @cbc.to_problem
        @problem.solve
        @problem.value_of(@variables[:plates]['pasta_al_pesto'])
      end

      def get_solution
        Solution.new(@problem)
      end

      private
      def set_variables
        @variables = {}
        @variables[:plates] = {}
        @variables[:packages] = {}
        @variables[:chosen_plates] = {}
        raw_plates = @cbc.int_var_array(@data.plates.size, 0..Cbc::INF, names: @data.plates)
        raw_packages = @cbc.int_var_array(@data.packages.size, 0..Cbc::INF, names: @data.packages)
        raw_chosen_plates = @cbc.bin_var_array(@data.plates.size, names: @data.plates.collect{|p| "#{p}_chosen"})
        raw_plates.each { |plate_var| @variables[:plates][plate_var.name] = plate_var }
        raw_packages.each { |packages_var| @variables[:packages][packages_var.name] = packages_var }
        raw_chosen_plates.each { |chosen_var| @variables[:chosen_plates][chosen_var.name.split('_chosen')[0]] = chosen_var }
      end

      def set_target
        packages = @data.packages
        @cbc.minimize(
            packages.inject(0) { |sum, package| sum + (@variables[:packages][package] * @data.prices[package]) }
        )
      end

      def subject_to
        min_variety
        plate_chosen_up
        plate_chosen_down
        min_meals
        min_plate
        max_plate
        min_ingredient
        needed_ingredient
      end

      def min_variety
        @data.meals.each do |meal|
          total_meal_variety = @data.plates_in_meals[meal].inject(0) { |sum, plate| sum + @variables[:chosen_plates][plate] }
          @cbc.enforce(total_meal_variety >= @data.meals_variety[meal])
        end
      end

      def plate_chosen_up
        @data.plates.each do |plate|
          @cbc.enforce(@variables[:plates][plate] <= (@data.upper_bound * @variables[:chosen_plates][plate]))
        end
      end

      def plate_chosen_down
        @data.plates.each do |plate|
          @cbc.enforce(@variables[:plates][plate] >= @variables[:chosen_plates][plate])
        end
      end

      def min_meals
        @data.meals.each do |meal|
          total_meal = @data.plates_in_meals[meal].inject(0) { |sum, plate| sum + @variables[:plates][plate] }
          @cbc.enforce(total_meal >= @data.needed_meals[meal])
        end
      end

      def min_plate
        @data.plates.each do |plate|
          @cbc.enforce(@variables[:plates][plate] >= @data.min_plates[plate])
        end
      end

      def max_plate
        @data.plates.each do |plate|
          @cbc.enforce(@variables[:plates][plate] <= @data.max_plates[plate])
        end
      end

      def min_ingredient
        @data.ingredients.each do |ingredient|
          total_ingredient = @data.packages.inject(0) do |sum, package|
            sum + (@data.packages_content[package][ingredient]*@variables[:packages][package])
          end
          @cbc.enforce(total_ingredient >= @data.min_ingredients[ingredient])
        end
      end
      def needed_ingredient
        @data.plates.each do |plate|
          @data.ingredients.each do |ingredient|
            bought_ingredient = @data.packages.inject(0) do |sum, package|
              sum + (@variables[:packages][package]*@data.packages_content[package][ingredient])
            end
            availability = @data.stock[ingredient]
            other_plates = @data.plates.select{|pa| pa != plate}.inject(0) do |sum, pa|
              sum + (@variables[:plates][pa]*@data.recipes[pa][ingredient])
            end
            current_plate = @variables[:plates][plate]*@data.recipes[plate][ingredient]
            total_ingredients = bought_ingredient - availability + other_plates
            @cbc.enforce(
                total_ingredients >= current_plate
            )
          end
        end
      end
    end
  end
end