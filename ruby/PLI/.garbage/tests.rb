require_relative '../Spesa/data'
require_relative '../Spesa/model'
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
pli = PLI::Spesa::Model.new(@valid_data)
puts pli.lp_model
sol = pli.solve
puts sol