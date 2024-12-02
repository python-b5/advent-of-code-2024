/* Advent of Code 2024
 * Day 01: Historian Hysteria
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "Math";
#import "Sort";
#import "String";

int_compare :: (a: int, b: int) -> int {
    if a > b return 1;
    if a < b return -1;
    return 0;
}

main :: () {
    input, success := read_entire_file("inputs/day_01.txt");
    assert(success);

    left_column: [..] int;
    right_column: [..] int;

    for split(input, "\n") {
        numbers := split(it, "   ");
        if numbers.count < 2 {
            break;
        }

        array_add(*left_column, string_to_int(numbers[0]));
        array_add(*right_column, string_to_int(numbers[1]));
    }

    quick_sort(left_column, int_compare);
    quick_sort(right_column, int_compare);

    difference_sum := 0;
    for 0..left_column.count - 1 {
        difference_sum += abs(left_column[it] - right_column[it]);
    }

    print("Part 1: %\n", difference_sum);

    right_column_occurrences: Table(int, int);
    similarity := 0;

    for left_column {
        occurrences, success := table_find(*right_column_occurrences, it);
        if !success {
            occurrences = 0;
            for other: right_column {
                if other == it {
                    occurrences += 1;
                }
            }

            table_set(*right_column_occurrences, it, occurrences);
        }

        similarity += it * occurrences;
    }

    print("Part 2: %\n", similarity);
}
