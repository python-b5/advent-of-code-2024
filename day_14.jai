/* Advent of Code 2024
 * Day 14: Restroom Redoubt
 */

#import "Basic";
#import "File";
#import "String";

Vector2_Int :: struct {
    x, y: int;
}

Robot :: struct {
    position, velocity: Vector2_Int;
}

main :: () {
    input, success := read_entire_file("inputs/day_14.txt");
    assert(success);

    lines := split(input, "\n");
    pop(*lines);
    defer array_free(lines);

    robots: [..] Robot;
    defer array_free(robots);

    for lines {
        vectors := split(it, " ");
        defer array_free(vectors);

        position := split(slice(vectors[0], 2, vectors[0].count - 2), ",");
        velocity := split(slice(vectors[1], 2, vectors[1].count - 2), ",");
        defer array_free(position);
        defer array_free(velocity);

        array_add(*robots, .{
            .{string_to_int(position[0]), string_to_int(position[1])},
            .{string_to_int(velocity[0]), string_to_int(velocity[1])}
        });
    }

    // The example input uses a different size for the space the robots are in,
    // so it's best to define constants for that so it can be easily changed.
    width :: 101;
    height :: 103;
    middle_x :: width / 2;
    middle_y :: height / 2;

    // We need the untouched robots array again for part 2, so we have to copy
    // it here.
    robots_part_1: [..] Robot;
    array_copy(*robots_part_1, robots);
    defer array_free(robots_part_1);

    robot_counts: [4] int;
    for *robots_part_1 {
        it.position.x += it.velocity.x * 100;
        it.position.y += it.velocity.y * 100;

        while it.position.x < 0       it.position.x += width;
        while it.position.x >= width  it.position.x -= width;
        while it.position.y < 0       it.position.y += height;
        while it.position.y >= height it.position.y -= height;

        if it.position.x != middle_x && it.position.y != middle_y {
            robot_counts[
                cast(int) (it.position.y > middle_y) * 2
                + cast(int) (it.position.x > middle_x)
            ] += 1;
        }
    }

    print(
        "Part 1: %\n",
        robot_counts[0] * robot_counts[1] * robot_counts[2] * robot_counts[3]
    );

    // The best way to find the Christmas tree picture seems to be looking for
    // the first second where no robots are on the same tile.
    seconds := 1;
    while true {
        occupied_tiles: [height][width] bool;
        duplicate_found := false;

        for *robots {
            it.position.x += it.velocity.x;
            it.position.y += it.velocity.y;

            if it.position.x < 0       it.position.x += width;
            if it.position.x >= width  it.position.x -= width;
            if it.position.y < 0       it.position.y += height;
            if it.position.y >= height it.position.y -= height;

            if occupied_tiles[it.position.y][it.position.x] {
                duplicate_found = true;
            } else {
                occupied_tiles[it.position.y][it.position.x] = true;
            }
        }

        if duplicate_found {
            seconds += 1;
        } else {
            print("Part 2: %\n", seconds);
            break;
        }
    }
}
