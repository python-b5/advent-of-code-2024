/* Advent of Code 2024
 * Day 18: RAM Run
 */

#import "Basic";
#import "File";
#import "Flat_Pool";
#import "Hash";
#import "Hash_Table";
#import "String";

// These need to be configurable to make using the sample input easy.
GRID_SIZE :: 71;
PART_1_BYTES :: 1024;

Vector2_Int :: struct {
    x, y: int;
}

Node :: struct {
    parent: *Node;
    position: Vector2_Int;
}

Vector2_Int_Set :: Table(
    Vector2_Int,
    void,
    (vector: Vector2_Int) -> u32 {
        return inline sdbm_hash(xx *vector, size_of(Vector2_Int));
    },
    #procedure_of_call(operator ==(Vector2_Int.{}, Vector2_Int.{}))
);

operator == :: (a: Vector2_Int, b: Vector2_Int) -> bool {
    return a.x == b.x && a.y == b.y;
}

solve_grid :: (grid: [GRID_SIZE][GRID_SIZE] bool) -> int {
    queue: [..] *Node;
    array_add(*queue, New(Node));
    defer array_free(queue);

    seen: Vector2_Int_Set;
    table_add(*seen, .{0, 0}, #run {});
    defer deinit(*seen);

    while queue.count {
        current := queue[0];
        array_ordered_remove_by_index(*queue, 0);

        if current.position == .{GRID_SIZE - 1, GRID_SIZE - 1} {
            path_length := 0;
            while current != null {
                path_length += 1;
                current = current.parent;
            }

            return path_length - 1;
        }

        for Vector2_Int.[
            .{current.position.x - 1, current.position.y},
            .{current.position.x + 1, current.position.y},
            .{current.position.x, current.position.y - 1},
            .{current.position.x, current.position.y + 1}
        ] {
            if
                it.x >= 0 && it.x < GRID_SIZE && it.y >= 0 && it.y < GRID_SIZE
                && !grid[it.y][it.x]
                && !table_contains(*seen, it)
            {
                new_node := New(Node);
                new_node.parent = current;
                new_node.position = it;

                array_add(*queue, new_node);
                table_add(*seen, it, #run {});
            }
        }
    }

    return -1;
}

main :: () {
    input, success := read_entire_file("inputs/day_18.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    grid: [GRID_SIZE][GRID_SIZE] bool;
    dropped_bytes := 0;

    for lines {
        position := split(it, ",");
        defer array_free(position);

        grid[string_to_int(position[1])][string_to_int(position[0])] = true;

        dropped_bytes += 1;
        if (dropped_bytes == PART_1_BYTES) {
            break;
        }
    }

    // Using a pool saves us time doing memory allocations in the solving
    // procedure. It's not a huge performance gain, but it's just about
    // noticeable.
    pool: Flat_Pool;
    defer reset(*pool);

    context.allocator.proc = flat_pool_allocator_proc;
    context.allocator.data = *pool;

    print("Part 1: %\n", solve_grid(grid));

    for dropped_bytes..lines.count - 2 {
        position := split(lines[it], ",");
        defer array_free(position);

        grid[string_to_int(position[1])][string_to_int(position[0])] = true;

        if solve_grid(grid) == -1 {
            print("Part 2: %\n", lines[it]);
            break;
        } else {
            // We'll run out of memory if we don't do this. With a smaller input
            // this might not be required, but for the size we're given the
            // program will crash if we don't do it.
            reset(*pool);
        }
    }
}
