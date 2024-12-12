/* Advent of Code 2024
 * Day 12: Garden Groups
 */

#import "Basic";
#import "File";
#import "Hash";
#import "Hash_Table";
#import "String";

Vector2_Int :: struct {
    x, y: int;
}

Vector2_Int_Set :: Table(
    Vector2_Int,
    void,
    (vector: Vector2_Int) -> u32 {
        return inline sdbm_hash(xx *vector, size_of(Vector2_Int));
    },
    (a: Vector2_Int, b: Vector2_Int) -> bool {
        return a.x == b.x && a.y == b.y;
    }
);

main :: () {
    input, success := read_entire_file("inputs/day_12.txt");
    assert(success);

    map := split(input, "\n");
    pop(*map);
    defer array_free(map);

    width := map[0].count;
    height := map.count;

    // Using an array like this appears to be faster than a table/set when we
    // don't need to count the elements.
    seen_positions := NewArray(width * height, bool);
    defer array_free(seen_positions);

    price_part_1 := 0;
    price_part_2 := 0;

    for x: 0..width - 1 {
        for y: 0..height - 1 {
            if seen_positions[y * width + x] {
                continue;
            }

            plant_type := map[y][x];
            position := Vector2_Int.{x, y};

            // Here, we need to count the elements (to find the area of the
            // plot) and iterate through them (to transfer all the plants in the
            // plot into seen_positions), so we're forced to use a set.
            plot: Vector2_Int_Set;
            table_add(*plot, position, #run {});
            defer deinit(*plot);

            // Because we're using arrays for fences_x and fences_y, we have to
            // store the perimeter separately.
            perimeter := 0;

            // These arrays store all the individual fences (like what is used
            // for part 1). fences_x stores vertical fences, and fences_y stores
            // horizontal ones - the arrays are named based on the direction the
            // fence is moved into from.
            //
            // The reason for using arrays is the same as with seen_positions,
            // though these need to be slightly bigger to fit all the fences.
            fences_x := NewArray((width + 1) * height, int);
            fences_y := NewArray(width * (height + 1), int);
            defer array_free(fences_x);
            defer array_free(fences_y);

            stack: [..] Vector2_Int;
            array_add(*stack, position);
            defer array_free(stack);

            while stack.count {
                current := pop(*stack);
                for *Vector2_Int.[
                    .{current.x - 1, current.y},
                    .{current.x + 1, current.y},
                    .{current.x, current.y - 1},
                    .{current.x, current.y + 1}
                ] {
                    if
                        it.x < 0 || it.x >= width || it.y < 0 || it.y >= height
                        || map[it.y][it.x] != plant_type
                    {
                        perimeter += 1;

                        // The first two indices are vertical sides, and the
                        // second two are horizontal.
                        if it_index < 2 {
                            if it_index == 0 {
                                it.x += 1;
                                fences_x[it.y * (width + 1) + it.x] = -1;
                            } else {
                                fences_x[it.y * (width + 1) + it.x] = 1;
                            }
                        } else {
                            if it_index == 2 {
                                it.y += 1;
                                fences_y[it.y * width + it.x] = -1;
                            } else {
                                fences_y[it.y * width + it.x] = 1;
                            }
                        }

                        continue;
                    }

                    if !table_contains(*plot, it) {
                        table_add(*plot, it, #run {});
                        array_add(*stack, it);
                    }
                }
            }

            price_part_1 += plot.count * perimeter;

            // I dislike having all this repeated code between vertical and
            // horizontal fences, but I'm not sure if there's a clean way to
            // make things less redundant. I'm just going to leave it.
            sides_x := 0;
            for fence_x: 0..width {
                in_side := false;
                side_bias: int;

                for fence_y: 0..height - 1 {
                    bias := fences_x[fence_y * (width + 1) + fence_x];
                    if bias != 0 {
                        if !in_side || bias != side_bias {
                            in_side = true;
                            side_bias = bias;
                            sides_x += 1;
                        }
                    } else if in_side {
                        in_side = false;
                    }
                }
            }

            sides_y := 0;
            for fence_y: 0..height {
                in_side := false;
                side_bias: int;

                for fence_x: 0..width - 1 {
                    bias := fences_y[fence_y * width + fence_x];
                    if bias != 0 {
                        if !in_side || bias != side_bias {
                            in_side = true;
                            side_bias = bias;
                            sides_y += 1;
                        }
                    } else if in_side {
                        in_side = false;
                    }
                }
            }

            price_part_2 += plot.count * (sides_x + sides_y);

            for plot {
                seen_positions[it_index.y * width + it_index.x] = true;
            }
        }
    }

    print("Part 1: %\nPart 2: %\n", price_part_1, price_part_2);
}
