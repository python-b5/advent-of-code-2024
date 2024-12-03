/* Advent of Code 2024
 * Day 03: Mull It Over
 */

#import "Basic";
#import "File";
#import "String";

main :: () {
    input, success := read_entire_file("inputs/day_03.txt");
    assert(success);

    result_sum := 0;
    result_sum_conditional := 0;
    mul_enabled := true;

    // The shortest valid instruction is 4 characters long (do()), so
    // technically with this range, if do() appeared at the very end of the
    // input, we would ignore it. However, that's not a concern, since at that
    // point there is no more room for mul() instructions anyway, meaning the
    // do() instruction would be effectively useless.
    for 0..input.count - 9 {
        // Don't waste time checking slices that aren't even a possibility.
        // The only valid instructions start with m (mul) or d (do/don't).
        if input[it] != #char "m" && input[it] != #char "d" {
            continue;
        }

        // The maximum instruction size is 12 (a mul() instruction with two
        // three-digit numbers).
        instruction := slice(input, it, ifx it >= input.count - 12 then input.count - it else 12);

        end_index := find_index_from_left(instruction, #char ")");
        if end_index == -1 {
            continue;
        }

        trimmed_instruction := slice(instruction, 0, end_index + 1);
        if slice(trimmed_instruction, 0, 4) == "mul(" {
            numbers := split(slice(trimmed_instruction, 4, trimmed_instruction.count - 5), ",");
            if numbers.count == 2 {
                valid := true;
                for numbers {
                    all_numbers := true;
                    for it {
                        if it < #char "0" || it > #char "9" {
                            all_numbers = false;
                            break;
                        }
                    }

                    if !all_numbers {
                        valid = false;
                        break;
                    }
                }

                if valid {
                    result := string_to_int(numbers[0]) * string_to_int(numbers[1]);
                    result_sum += result;

                    if mul_enabled {
                        result_sum_conditional += result;
                    }
                }
            }
        } else if trimmed_instruction == {
            case "do()";    mul_enabled = true;
            case "don't()"; mul_enabled = false;
        }
    }

    print("Part 1: %\nPart 2: %\n", result_sum, result_sum_conditional);
}
