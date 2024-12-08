/* Advent of Code 2024
 * Day 07: Bridge Repair
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "String";

Operator :: enum {
    ADD;
    MULTIPLY;
    CONCATENATE;
}

// Finds all permutations of an arbitrary length made up of elements from a
// given array. Repeats are allowed.
find_permutations :: (elements: [] $T, length: int) -> [][..] T {
    max_permutations := elements.count;
    for 1..length {
        max_permutations *= elements.count;
    }

    permutations: [..][..] T;
    array_reserve(*permutations, max_permutations);

    stack: [..][..] T;
    array_reserve(*stack, max_permutations);
    defer array_free(stack);

    for elements {
        permutation: [..] T;
        array_reserve(*permutation, length);
        array_add(*permutation, it);
        array_add(*stack, permutation);
    }

    while stack.count {
        permutation := pop(*stack);
        if permutation.count == length {
            array_add(*permutations, permutation);
            continue;
        }

        for elements {
            new_permutation: [..] T;
            array_reserve(*new_permutation, length);

            for permutation {
                array_add(*new_permutation, it);
            }

            array_add(*new_permutation, it);
            array_add(*stack, new_permutation);
        }

        array_free(permutation);
    }

    return permutations;
}

is_equation_possible :: (
    required_result: int,
    numbers: [] int,
    permutations: [][..] Operator
) -> bool {
    // Not much of an ingenious solution here. There is probably a faster way to
    // solve this than bruteforcing (again...), but this works well enough.
    for permutation: permutations {
        result := numbers[0];
        for 1..numbers.count - 1 {
            if permutation[it - 1] == {
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

        if result == required_result {
            return true;
        }
    }

    return false;
}

main :: () {
    time := current_time_monotonic();
    input, success := read_entire_file("inputs/day_07.txt");
    assert(success);

    // There's a lot of duplicated code between part 1 and part 2 here, but I'm
    // not sure how to get rid of it cleanly.
    total_part_1 := 0;
    total_part_2 := 0;

    memoized_permutations_part_1: Table(int, [][..] Operator);
    memoized_permutations_part_2: Table(int, [][..] Operator);

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

        operator_count := numbers.count - 1;

        permutations_part_1, success := table_find(
            *memoized_permutations_part_1,
            operator_count
        );

        permutations_part_2: [][..] Operator;

        if success {
            // If we previously memoized the permutations for part 1 for this
            // length, we will have also done so for part 2.
            permutations_part_2, _ = table_find(
                *memoized_permutations_part_2,
                operator_count
            );
        } else {
            permutations_part_1 = find_permutations(
                Operator.[.ADD, .MULTIPLY],
                operator_count
            );

            permutations_part_2 = find_permutations(
                Operator.[.ADD, .MULTIPLY, .CONCATENATE],
                operator_count
            );

            table_add(
                *memoized_permutations_part_1,
                operator_count,
                permutations_part_1
            );

            table_add(
                *memoized_permutations_part_2,
                operator_count,
                permutations_part_2
            );
        }

        if is_equation_possible(required_result, numbers, permutations_part_1) {
            total_part_1 += required_result;
        }

        if is_equation_possible(required_result, numbers, permutations_part_2) {
            total_part_2 += required_result;
        }
    }

    for memoized_permutations_part_1 {
        array_free(it);
    }

    for memoized_permutations_part_2 {
        array_free(it);
    }

    print("Part 1: %\nPart 2: %\n", total_part_1, total_part_2);
    print("Time: % ms\n", to_milliseconds(current_time_monotonic() - time));
}
