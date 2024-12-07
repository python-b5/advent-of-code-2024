/* Advent of Code 2024
 * Day 07: Bridge Repair
 */

#import "Basic";
#import "File";
#import "String";

Operator :: enum {
    ADD;
    MULTIPLY;
    CONCATENATE;
}

// Finds all permutations of an arbitrary length made up of elements from a
// given array. Repeats are allowed.
find_permutations :: (elements: [] $T, length: int) -> [][..] T {
    permutations: [..][..] T;
    queue: [..][..] T;

    for elements {
        permutation: [..] T;
        array_add(*permutation, it);
        array_add(*queue, permutation);
    }

    while queue.count {
        permutation := pop(*queue);
        if permutation.count == length {
            array_add(*permutations, permutation);
            continue;
        }

        for elements {
            new_permutation: [..] T;
            array_copy(*new_permutation, permutation);
            array_add(*new_permutation, it);
            array_add(*queue, new_permutation);
        }
    }

    return permutations;
}

is_equation_possible :: (
    required_result: int,
    numbers: [] int,
    operators: [] Operator
) -> bool {
    // Not much of an ingenious solution here. There is probably a faster way to
    // solve this than bruteforcing (again...), but this works well enough.
    for operators: find_permutations(operators, numbers.count - 1) {
        result := numbers[0];
        for 1..numbers.count - 1 {
            if operators[it - 1] == {
                case .ADD; result += numbers[it];
                case .MULTIPLY; result *= numbers[it];

                case .CONCATENATE;
                    power := 10;
                    next_number := numbers[it];

                    while power <= next_number {
                        power *= 10;
                    }

                    result *= power;
                    result += next_number;
            }
        }

        array_free(operators);

        if result == required_result {
            return true;
        }
    }

    return false;
}

main :: () {
    input, success := read_entire_file("inputs/day_07.txt");
    assert(success);

    total_part_1 := 0;
    total_part_2 := 0;

    for split(input, "\n") {
        if it == "" {
            continue;
        }

        parts := split(it, ": ");
        required_result := string_to_int(parts[0]);

        numbers: [..] int;
        for split(parts[1], " ") {
            array_add(*numbers, string_to_int(it));
        }

        if is_equation_possible(required_result, numbers, .[.ADD, .MULTIPLY]) {
            total_part_1 += required_result;
        }

        if is_equation_possible(
            required_result,
            numbers,
            .[.ADD, .MULTIPLY, .CONCATENATE]
        ) {
            total_part_2 += required_result;
        }
    }

    print("Part 1: %\nPart 2: %\n", total_part_1, total_part_2);
}
