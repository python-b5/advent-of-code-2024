/* Advent of Code 2024
 * Day 20: Race Condition
 */

#import "Basic";
#import "File";
#import "Flat_Pool";
#import "Hash";
#import "Hash_Table";
#import "Math";
#import "String";

Vector2_Int :: struct {
    x, y: int;
}

Node :: struct {
    cost: int;
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

// Traverse the whole track and fill a (flattened two-dimensional) array with
// the distances from a given start position to every other position.
fill_distances_array :: (
    track: [][..] bool,
    width: int,
    start: Vector2_Int,
    distances: [] int
) {
    queue: [..] *Node;
    defer array_free(queue);

    start_node := New(Node);
    start_node.position = start;
    array_add(*queue, start_node);

    seen: Vector2_Int_Set;
    table_add(*seen, start, #run {});
    defer deinit(*seen);

    while queue.count {
        current := queue[0];
        array_ordered_remove_by_index(*queue, 0);

        index := current.position.y * width + current.position.x;
        if distances[index] == 0 {
            distances[index] = current.cost;
        }

        for Vector2_Int.[
            .{current.position.x - 1, current.position.y},
            .{current.position.x + 1, current.position.y},
            .{current.position.x, current.position.y - 1},
            .{current.position.x, current.position.y + 1}
        ] {
            if !track[it.y][it.x] && !table_contains(*seen, it) {
                new_node := New(Node);
                new_node.cost = current.cost + 1;
                new_node.position = it;

                array_add(*queue, new_node);
                table_add(*seen, it, #run {});
            }
        }
    }
}

find_efficient_cheats :: (
    track: [][..] bool,
    width: int,
    height: int,
    fastest_time: int,
    distances_from_start: [] int,
    distances_to_end: [] int,
    cheat_distance: int
) -> int {
    efficient_cheats := 0;
    for x1: 1..width - 2 {
        for y1: 1..height - 2 {
            for x2: x1 - cheat_distance..x1 + cheat_distance {
                for y2: y1 - cheat_distance..y1 + cheat_distance {
                    if
                        x2 <= 0 || x2 >= width - 1
                        || y2 <= 0 || y2 >= height - 1
                    {
                        continue;
                    }

                    distance := abs(x2 - x1) + abs(y2 - y1);
                    if
                        distance <= cheat_distance
                        && !track[y1][x1] && !track[y2][x2]
                        && fastest_time - (
                            distances_from_start[y1 * width + x1]
                            + distance
                            + distances_to_end[y2 * width + x2]
                        ) >= 100
                    {
                        efficient_cheats += 1;
                    }
                }
            }
        }
    }

    return efficient_cheats;
}

main :: () {
    input, success := read_entire_file("inputs/day_20.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    track: [..][..] bool;
    defer {
        for track {
            array_free(it);
        }

        array_free(track);
    }

    start, end: Vector2_Int;

    for line, y: lines {
        if line == "" {
            continue;
        }

        row: [..] bool;
        for char, x: line {
            array_add(*row, char == #char "#");

            if char == #char "S" {
                start = .{x, y};
            } else if char == #char "E" {
                end = .{x, y};
            }
        }

        array_add(*track, row);
    }

    width := track[0].count;
    height := track.count;

    distances_size := width * height;
    distances_from_start := NewArray(distances_size, int);
    distances_to_end := NewArray(distances_size, int);
    defer array_free(distances_from_start);
    defer array_free(distances_to_end);

    // Yet again, it's faster to use a pool when we're doing a bunch of graph
    // traversal (though the performance gain in this case is probably
    // negligable, since we're only running BFS twice).
    pool: Flat_Pool;
    defer reset(*pool);

    new_context := context;
    new_context.allocator.proc = flat_pool_allocator_proc;
    new_context.allocator.data = *pool;

    push_context new_context {
        fill_distances_array(track, width, start, distances_from_start);
        fill_distances_array(track, width, end, distances_to_end);
    }

    fastest_time := distances_to_end[start.y * width + start.x];
    print(
        "Part 1: %\nPart 2: %\n",
        find_efficient_cheats(
            track,
            width,
            height,
            fastest_time,
            distances_from_start,
            distances_to_end,
            2
        ),
        find_efficient_cheats(
            track,
            width,
            height,
            fastest_time,
            distances_from_start,
            distances_to_end,
            20
        )
    );
}
