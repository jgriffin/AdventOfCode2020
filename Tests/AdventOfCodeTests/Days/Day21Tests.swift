//
//
// Created by John Griffin on 11/4/21
//

import ParserCombinator
import XCTest

final class Day21Tests: XCTestCase {
    let input = resourceURL(filename: "Day21Input.txt")!.readContents()!

    let example = """
    mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
    trh fvjkl sbzzf mxmxvkd (contains dairy)
    sqjhc fvjkl (contains soy)
    sqjhc mxmxvkd sbzzf (contains fish)
    """
}

extension Day21Tests {
    func testAllergensExample() {
        let foods = Self.foods.match(example)!
        let ingredients = foods.flatMap(\.ingredients).asSet
        let allergens = foods.flatMap(\.allergens).asSet
        XCTAssertEqual(allergens.count, 3)

        let allergenPossibilities = allergenPossibilitesFrom(foods)
        let ingredientAllergens = reduceAllergenPossibilites(allergenPossibilities)

        let ingredientsWithoutAlergens = ingredients.subtracting(ingredientAllergens.keys)
        let ingredientsWithoutAllergensOccurences = foods.flatMap(\.ingredients)
            .filter { ingredientsWithoutAlergens.contains($0) }

        XCTAssertEqual(ingredientsWithoutAllergensOccurences.count, 5)
        
        let dangerousAllergens = ingredientAllergens
            .sorted(by: \.value).map(\.key).joined(separator: ",")
        XCTAssertEqual(dangerousAllergens, "mxmxvkd,sqjhc,fvjkl")
    }

    func testAllergensInput() {
        let foods = Self.foods.match(input)!
        let ingredients = foods.flatMap(\.ingredients).asSet
        let allergens = foods.flatMap(\.allergens).asSet
        XCTAssertEqual(allergens.count, 8)

        let allergenPossibilities = allergenPossibilitesFrom(foods)
        let ingredientAllergens = reduceAllergenPossibilites(allergenPossibilities)

        let ingredientsWithoutAlergens = ingredients.subtracting(ingredientAllergens.keys)
        let ingredientsWithoutAllergensOccurences = foods.flatMap(\.ingredients)
            .filter { ingredientsWithoutAlergens.contains($0) }

        XCTAssertEqual(ingredientsWithoutAllergensOccurences.count, 2061)
        
        let dangerousAllergens = ingredientAllergens
            .sorted(by: \.value).map(\.key).joined(separator: ",")
        XCTAssertEqual(dangerousAllergens, "cdqvp,dglm,zhqjs,rbpg,xvtrfz,tgmzqjz,mfqgx,rffqhl")
    }

    typealias Food = (ingredients: Set<String>, allergens: Set<String>)
    typealias Allergen = String
    typealias Ingredient = String
    typealias AllergenPossibilities = [Allergen: Set<Ingredient>]
    typealias IngredientPossibilities = [Ingredient: Set<Allergen>]

    func allergenPossibilitesFrom(_ foods: [Food]) -> AllergenPossibilities {
        foods
            .reduce(into: AllergenPossibilities()) { result, food in
                food.allergens
                    .forEach { allergen in
                        if result[allergen] == nil {
                            result[allergen] = food.ingredients
                        } else {
                            result[allergen]!.formIntersection(food.ingredients)
                        }
                    }
            }
    }

    func reduceAllergenPossibilites(_ allergenPossibilities: AllergenPossibilities) -> [Ingredient: Allergen] {
        var ingredientAllergens = [Ingredient: Allergen]()

        var allergenPossibilities = allergenPossibilities

        while true {
            let ingredientPossibilites = ingredientPossibilitiesFrom(allergenPossibilities)

            let identifiedIngredientAllergens = ingredientPossibilites
                .reduce(into: [Ingredient: Allergen]()) { result, ingredientAllergens in
                    let (ingredient, allergens) = ingredientAllergens
                    guard let allergen = allergens.only() else { return }
                    result[ingredient] = allergen
                }

            guard !identifiedIngredientAllergens.isEmpty else {
                break
            }

            ingredientAllergens.merge(identifiedIngredientAllergens) { _, _ in fatalError() }

            let identifiedAllergens = identifiedIngredientAllergens.map(\.value)
            identifiedAllergens.forEach { allergen in
                allergenPossibilities[allergen] = nil
            }
        }

        return ingredientAllergens
    }

    func ingredientPossibilitiesFrom(_ allergenPossibilities: AllergenPossibilities) -> IngredientPossibilities {
        allergenPossibilities
            .reduce(into: IngredientPossibilities()) { result, allergenPossibilities in
                let (allergen, ingredients) = allergenPossibilities
                ingredients.forEach { ingredient in
                    result[ingredient, default: Set()].insert(allergen)
                }
            }
    }
}

extension Day21Tests {
    func testParseExample() {
        let foods = Self.foods.match(example)!
        XCTAssertEqual(foods.count, 4)
    }

    func testParseInput() {
        let foods = Self.foods.match(input)!
        XCTAssertEqual(foods.count, 36)
    }

    func testParseFoodExample() {
        let food = Self.food.match("mxmxvkd kfcds sqjhc nhms (contains dairy, fish)")
        XCTAssertNotNil(food)
    }
}

extension Day21Tests {
    typealias P = Parser

    static let ingredient = P.letters.asString
    static let ingredients = ingredient.oneOrMore(separatedBy: P.whitespace)
    static let allergen = P.letters.asString
    static let allergens = allergen.oneOrMore(separatedBy: ", ")
    static let contains = zip(P.literal(" (contains "), allergens, P.literal(")"))
        .map(\.1)
    static let food = zip(ingredients, contains)
        .map { (ingredients: $0.asSet, allergens: $1.asSet) }
    static let foods = food.oneOrMore(separatedBy: P.newline).ignoring(P.whitespaceAndNewline.zeroOrMore())
}
