require 'test/unit'
require_relative '../data'
require_relative '../model'
require 'test/unit/util/backtracefilter'

class TestSpesaModel < Test::Unit::TestCase
  def correct_model
    '
    Minimize
    + 2 confezione_pancetta + 1.5 scatola_uova + 2.5 barattolo_di_pesto

    Subject To
    + carbonara_chosen + pasta_al_pesto_chosen >= 2
    + carbonara - 100 carbonara_chosen <= 0
    + pasta_al_pesto - 100 pasta_al_pesto_chosen <= 0
    + carbonara - 1 carbonara_chosen >= 0
    + pasta_al_pesto - 1 pasta_al_pesto_chosen >= 0
    + carbonara + pasta_al_pesto >= 5
    + carbonara >= 0
    + pasta_al_pesto >= 0
    + carbonara <= 10
    + pasta_al_pesto <= 10
    + 3 barattolo_di_pesto >= 0
    + 2 confezione_pancetta >= 0
    + 4 scatola_uova >= 0
    + 3 barattolo_di_pesto + pasta_al_pesto >= 0
    + 2 confezione_pancetta - 1 carbonara >= 0
    + 4 scatola_uova + 0.5 pasta_al_pesto - 1 carbonara >= 0
    + 3 barattolo_di_pesto - 1 pasta_al_pesto >= 0
    + 2 confezione_pancetta + carbonara >= 0
    + 4 scatola_uova + carbonara - 0.5 pasta_al_pesto >= 0

    Bounds
    0 <= carbonara <= +inf
    0 <= pasta_al_pesto <= +inf
    0 <= confezione_pancetta <= +inf
    0 <= scatola_uova <= +inf
    0 <= barattolo_di_pesto <= +inf

    Generals
    carbonara
    pasta_al_pesto
    confezione_pancetta
    scatola_uova
    barattolo_di_pesto

    Binaries
    carbonara_chosen
    pasta_al_pesto_chosen

    End
    '
  end

  def setup
    plates = {pranzo: ['carbonara', 'pasta al pesto']}
    ingredients = %w(pesto pancetta uova)
    packages = ['confezione_pancetta', 'scatola uova', 'barattolo di pesto']
    @valid_data = ::PLI::Spesa::Data.new(plates, ingredients, packages)
    @valid_data.upper_bound = 100
    @valid_data.prices = {
        confezione_pancetta: 2,
        scatola_uova: 1.5,
        barattolo_di_pesto: 2.5
    }
    @valid_data.stock = {}
    @valid_data.meals_variety = {
        pranzo: 2
    }
    @valid_data.needed_meals = {pranzo: 5}
    @valid_data.min_plates = {}
    @valid_data.max_plates = @valid_data.max_plates = {
        carbonara: 10,
        pasta_al_pesto: 10
    }
    @valid_data.min_ingredients = {}
    @valid_data.packages_content = {
        confezione_pancetta: {pancetta: 2},
        scatola_uova: {uova: 4},
        barattolo_di_pesto: {pesto: 3}
    }
    @valid_data.recipes = {
        carbonara: {uova: 1, pancetta: 1},
        pasta_al_pesto: {pesto: 1, uova: 0.5}
    }

    @invalid_data = PLI::Spesa::Data.new(plates, packages, ingredients)
  end
  def test_data_is_valid
    assert_true(@valid_data.is_valid?)
    assert_false(@invalid_data.is_valid?)
  end
  def test_model_init_with_valid_data
    assert_nothing_raised{PLI::Spesa::Model.new(@valid_data)}
  end
  def test_model_not_init_with_invalid_data
    assert_raise(PLI::Exceptions::DataNotValid){PLI::Spesa::Model.new(@invalid_data)}
  end
  def test_model_in_lp_is_correct
    model = PLI::Spesa::Model.new(@valid_data)
    assert_equal(correct_model.gsub(/\s+/, ''), model.lp_model.gsub(/\s+/, ''))
  end
end