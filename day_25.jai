/* Advent of Code 2024
 * Day 25: Code Chronicle
 */

#import "Basic";
#import "File";
#import "String";

main :: () {
    input, success := read_entire_file("inputs/day_25.txt");
    assert(success);

    groups := split(input, "\n\n");
    defer array_free(groups);

    keys: [..][5] int;
    locks: [..][5] int;
    defer array_free(keys);
    defer array_free(locks);

    for groups {
        lines := split(it, "\n");
        defer array_free(lines);

        if lines[0] == "....." {
            key: [5] int;
            for x: 0..4 {
                height := 0;
                for #v2 < y: 1..5 {
                    if lines[y][x] == #char "#" {
                        height += 1;
                    } else {
                        break;
                    }
                }

                key[x] = height;
            }

            array_add(*keys, key);
        } else {
            lock: [5] int;
            for x: 0..4 {
                height := 0;
                for y: 1..5 {
                    if lines[y][x] == #char "#" {
                        height += 1;
                    } else {
                        break;
                    }
                }

                lock[x] = height;
            }

            array_add(*locks, lock);
        }
    }

    fitting_pairs := 0;
    for key: keys {
        for lock: locks {
            fits := true;
            for 0..4 {
                if key[it] + lock[it] > 5 {
                    fits = false;
                    break;
                }
            }

            if fits {
                fitting_pairs += 1;
            }
        }
    }

    print("Part 1: %\n", fitting_pairs);
}
