/* Advent of Code 2024
 * Day 06: Guard Gallivant
 */

#import "Basic";
#import "File";
#import "Hash";
#import "String";

using Hash_Table :: #import "Hash_Table";
#poke_name Hash_Table operator ==;

Vector2_Int :: struct {
    x, y: int;
}

// Maybe the guard doesn't have to be a struct, but it makes the program more
// readable and doesn't have any performance impact. It's also possible
// "direction" could be an enum, but then the simulation code would be a little
// less clean...
Guard :: struct {
    position, direction: Vector2_Int;
}

// Inlining all these procedures makes the bruteforcing faster. Maybe.
operator == :: inline (a: Vector2_Int, b: Vector2_Int) -> bool {
    return a.x == b.x && a.y == b.y;
}

Vector2_Int_Table :: Table(Vector2_Int, void, (vector: Vector2_Int) -> u32 {
    return inline sdbm_hash(xx *vector, size_of(Vector2_Int));
});

// This function behaves differently depending on which part of the puzzle it is
// supposed to be solving. This is important to avoid unnecessarily wasting time
// on recording the unique positions visited by the guard during part 2, which
// slows the bruteforcing down considerably. While this procedure returns
// multiple values (the set of unique positions, and whether the guard entered a
// loop), the first one will always be an empty set during part 2.
simulate_guard :: inline (
    map: [..][..] bool,
    width: int,
    height: int,
    initial_guard: Guard,
    part: int
) -> Vector2_Int_Table, bool {
    unique_positions: Vector2_Int_Table;

    // This is _much_ faster than using a set. I'm keeping this as a flat array
    // to avoid unnecessary allocations - I tried using a flat array for the map
    // itself too, but the overhead of calculating the index constantly seemed
    // to slow the program down very slightly (by milliseconds - I'm splitting
    // hairs here!).
    previous_guard_states := NewArray(width * height, [4] bool);
    defer array_free(previous_guard_states);

    guard := initial_guard;
    while true {
        // It looks a little weird, but using #run {} allows you to add keys to
        // a table with void as the value type (which is useful to lower memory
        // usage when using a table as a set).
        if part == 1 {
            if !table_contains(*unique_positions, guard.position) {
                table_add(*unique_positions, guard.position, #run {});
            }
        } else {
            position_index := guard.position.x * width + guard.position.y;

            direction_index: int;
            if      guard.direction == .{1, 0}  direction_index = 0;
            else if guard.direction == .{0, 1}  direction_index = 1;
            else if guard.direction == .{-1, 0} direction_index = 2;
            else if guard.direction == .{0, -1} direction_index = 3;

            if previous_guard_states[position_index][direction_index] {
                return unique_positions, true;
            } else {
                previous_guard_states[position_index][direction_index] = true;
            }
        }

        guard.position.x += guard.direction.x;
        guard.position.y += guard.direction.y;

        if
            guard.position.x < 0 || guard.position.x >= width
            || guard.position.y < 0 || guard.position.y >= height
        {
            break;
        }

        if map[guard.position.y][guard.position.x] {
            guard.position.x -= guard.direction.x;
            guard.position.y -= guard.direction.y;
            guard.direction = .{-guard.direction.y, guard.direction.x};
        }
    }

    return unique_positions, false;
}

main :: () {
    input, success := read_entire_file("inputs/day_06.txt");
    assert(success);

    map: [..][..] bool;
    guard: Guard;
    guard.direction = .{0, -1};

    for line, y: split(input, "\n") {
        if line == "" {
            continue;
        }

        row: [..] bool;
        for char, x: line {
            array_add(*row, ifx char == #char "#" then true else false);

            if char == #char "^" {
                guard.position = .{x, y};
            }
        }

        array_add(*map, row);
    }

    width := map[0].count;
    height := map.count;

    unique_positions, _ := simulate_guard(map, width, height, guard, 1);
    print("Part 1: %\n", unique_positions.count);

    loop_causing_obstructions := 0;
    for unique_positions {
        map[it_index.y][it_index.x] = true;

        _, entered_loop := simulate_guard(map, width, height, guard, 2);
        if entered_loop {
            loop_causing_obstructions += 1;
        }

        map[it_index.y][it_index.x] = false;
    }

    print("Part 2: %\n", loop_causing_obstructions);
}
