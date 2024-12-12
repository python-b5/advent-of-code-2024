/* Advent of Code 2024
 * Day 11: Plutonian Pebbles
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "String";

add_stones :: (stones: *Table(int, int), stone: int, amount: int) {
    old_amount, success := table_find(stones, stone);
    if success {
        table_set(stones, stone, old_amount + amount);
    } else {
        table_add(stones, stone, amount);
    }
}

get_stone_count :: (stones: *Table(int, int)) -> int {
    stone_count := 0;
    for stones {
        stone_count += it;
    }

    return stone_count;
}

main :: () {
    input, success := read_entire_file("inputs/day_11.txt");
    assert(success);

    stones: Table(int, int);
    defer deinit(*stones);

    for split(input, " ") {
        table_add(*stones, string_to_int(it), 1);
    }

    for 1..75 {
        // We have to track the new stones separately to avoid processing
        // the same stones multiple times in the same blink.
        new_stones: Table(int, int);
        defer deinit(*new_stones);

        for stones {
            if it_index == 0 {
                add_stones(*new_stones, 1, it);
            } else {
                stone := it_index;
                digit_count := 1;

                while stone >= 10 {
                    stone /= 10;
                    digit_count += 1;
                }

                if digit_count % 2 == 0 {
                    divisor := 1;
                    for 1..digit_count / 2 {
                        divisor *= 10;
                    }

                    add_stones(*new_stones, it_index / divisor, it);
                    add_stones(*new_stones, it_index % divisor, it);
                } else {
                    add_stones(*new_stones, it_index * 2024, it);
                }
            }

            table_set(*stones, it_index, 0);
        }

        for new_stones {
            add_stones(*stones, it_index, it);
        }

        // We have to wait to remove stones until everything for this blink has
        // been processed.
        for stones {
            if it == 0 {
                remove it;
            }
        }

        if it == 25 {
            print("Part 1: %\n", get_stone_count(*stones));
        }
    }

    print("Part 2: %\n", get_stone_count(*stones));
}
