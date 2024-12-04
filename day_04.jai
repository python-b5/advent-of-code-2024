/* Advent of Code 2024
 * Day 04: Ceres Search
 */

#import "Basic";
#import "File";
#import "String";

// The Vector2 struct in the Math module uses floats, which we don't want since
// we're using this struct as a modifier for array indices.
Vector2_Int :: struct {
    x, y: int;
}

main :: () {
    input, success := read_entire_file("inputs/day_04.txt");
    assert(success);

    rows := split(input, "\n");
    rows.count -= 1; // We're assuming a trailing newline.

    xmas_count := 0;
    for row, y: rows {
        for char, x: row {
            if char == #char "X" {
                // There's no point checking for the remaining letters if there
                // isn't space for them anyway.
                right_allowed := x <= row.count - 4;
                left_allowed  := x >= 3;

                if right_allowed && slice(row, x + 1, 3) == "MAS" {
                    xmas_count += 1;
                }

                if left_allowed && slice(row, x - 3, 3) == "SAM" {
                    xmas_count += 1;
                }

                directions: [..] Vector2_Int;

                if y <= rows.count - 4 {
                    array_add(*directions, .{0, 1});
                    if right_allowed array_add(*directions, .{1, 1});
                    if left_allowed  array_add(*directions, .{-1, 1});
                }

                if y >= 3 {
                    array_add(*directions, .{0, -1});
                    if right_allowed array_add(*directions, .{1, -1});
                    if left_allowed  array_add(*directions, .{-1, -1});
                }

                for direction: directions {
                    found_letters: [3] u8;

                    scan_x := x;
                    scan_y := y;

                    for 0..2 {
                        scan_x += direction.x;
                        scan_y += direction.y;
                        found_letters[it] = rows[scan_y][scan_x];
                    }

                    if xx found_letters == "MAS" {
                        xmas_count += 1;
                    }
                }
            }
        }
    }

    print("Part 1: %\n", xmas_count);

    x_mas_count := 0;
    for y: 1..rows.count - 2 {
        for x: 1..rows[y].count - 2 {
            // The middle character will always be A.
            if rows[y][x] == #char "A" {
                // Maybe there's a better way to do this.
                if (
                    (
                        rows[y - 1][x - 1] == #char "M"
                        && rows[y + 1][x + 1] == #char "S"
                    ) || (
                        rows[y - 1][x - 1] == #char "S"
                        && rows[y + 1][x + 1] == #char "M"
                    )
                ) && (
                    (
                        rows[y + 1][x - 1] == #char "M"
                        && rows[y - 1][x + 1] == #char "S"
                    ) || (
                        rows[y + 1][x - 1] == #char "S"
                        && rows[y - 1][x + 1] == #char "M"
                    )
                ) {
                    x_mas_count += 1;
                }
            }
        }
    }

    print("Part 2: %\n", x_mas_count);
}
