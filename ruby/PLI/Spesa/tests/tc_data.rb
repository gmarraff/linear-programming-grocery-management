require 'test/unit'
require_relative '../data'

class TestSpesaData < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @obj = PLI::Spesa::Data.new({pranzo:['carbonara']}, ['uova', 'pancetta'], ['pancetta mondadori'])
  end

  def test_constructor_correct
    assert_equal(%w(carbonara), @obj.plates)
    assert_equal(%w(uova pancetta), @obj.ingredients)
    assert_equal(%w(pancetta_mondadori), @obj.packages)
    assert_equal(%w(pranzo), @obj.meals)
    assert_equal({'pranzo'=>['carbonara']}, @obj.plates_in_meals)
  end
  def test_constructor_incorrect
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new(nil, [], [])}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({pranzo:['carbonara']}, nil, [])}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({pranzo:['carbonara']}, ['uova', 'pancetta'], nil)}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({a: {b: {c: []}}}, nil, nil)}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({a: 'a'}, nil, nil)}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({a: []}, nil, nil)}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({pranzo:['carbonara']}, 'not_valid', nil)}
    assert_raise( PLI::Exceptions::SetNotValid ){PLI::Spesa::Data.new({pranzo:['carbonara']}, ['uova'], 'not_valid')}
    assert_raise( PLI::Exceptions::SetEmpty ){PLI::Spesa::Data.new({}, ['uova'], ['pancetta'])}
    assert_raise( PLI::Exceptions::SetEmpty ){PLI::Spesa::Data.new({pranzo:['carbonara']}, [], ['pancetta'])}
    assert_raise( PLI::Exceptions::SetEmpty ){PLI::Spesa::Data.new({pranzo:['carbonara']}, ['uova'], [])}
  end
  def test_m_correct
    @obj.upper_bound = 5
    assert_equal(5, @obj.upper_bound)
  end
  def test_m_incorrect
    assert_raise( TypeError ){@obj.upper_bound = 5.5}
    assert_raise( TypeError ){@obj.upper_bound = 'a'}
  end

  def test_prices_correct
    @obj.prices = {'pancetta mondadori'=>5}
    assert_equal({'pancetta_mondadori'=>5}, @obj.prices)
  end
  def test_validation_correct
    @obj.prices = {pancetta_mondadori: 5}
    @obj.meals_variety = {pranzo: 1}
    @obj.upper_bound = 7
    @obj.packages_content = {pancetta_mondadori: {pancetta: 1}}
    @obj.recipes = {carbonara: {pancetta: 1, uova: 1}}
    @obj.needed_meals = {pranzo: 7}
    @obj.max_plates= {carbonara: 7}
    assert_equal(true, @obj.is_valid?)
  end
  def test_validation_incorrect
    assert_equal(false, @obj.is_valid?)
  end
end