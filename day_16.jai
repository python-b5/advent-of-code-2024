/* Advent of Code 2024
 * Day 16: Reindeer Maze
 */

#import "Basic";
#import "Binary_Heap";
#import "File";
#import "Hash";
#import "Hash_Table";
#import "String";

Vector2_Int :: struct {
    x, y: int;
}

Node :: struct {
    parent: *Node;
    cost: int;
    position: Vector2_Int;
}

// This is used for the table of seen states. The direction isn't stored in Node
// because it is inferred from the parent's position, but we have to store it
// here.
Reindeer_State :: struct {
    position, direction: Vector2_Int;
}

operator == :: (a: Vector2_Int, b: Vector2_Int) -> bool {
    return a.x == b.x && a.y == b.y;
}

array_free_2d :: (array: [..][..] $T) {
    for array {
        array_free(it);
    }

    array_free(array);
}

main :: () {
    input, success := read_entire_file("inputs/day_16.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    map: [..][..] bool;
    defer array_free_2d(map);

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

        array_add(*map, row);
    }

    width := map[0].count;
    height := map.count;

    heap: Heap(*Node, (left: *Node, right: *Node) -> bool {
        return left.cost <= right.cost;
    });

    seen: Table(
        Reindeer_State,
        int,
        (state: Reindeer_State) -> u32 {
            return inline sdbm_hash(xx *state, size_of(Reindeer_State));
        },
        (a: Reindeer_State, b: Reindeer_State) -> bool {
            return a.position == b.position && a.direction == b.direction;
        }
    );

    defer heap_free(heap);
    defer deinit(*seen);

    start_node := New(Node);
    start_node.position = start;
    heap_add(*heap, start_node);
    table_set(*seen, .{start_node.position, .{1, 0}}, 0);

    minimum_cost := -1;

    best_paths: [..][..] Vector2_Int;
    defer array_free_2d(best_paths);

    while !heap_is_empty(heap) {
        current := heap_pop(*heap);

        if current.position == end {
            if minimum_cost == -1 {
                minimum_cost = current.cost;
                print("Part 1: %\n", minimum_cost);
            }

            if current.cost == minimum_cost {
                path: [..] Vector2_Int;
                while current != null {
                    array_insert_at(*path, current.position, 0);
                    current = current.parent;
                }

                array_add(*best_paths, path);
                continue;
            } else {
                // We're using Djikstra's algorithm, so we know there will be no
                // more best paths after this.
                break;
            }
        }

        for Vector2_Int.[.{-1, 0}, .{1, 0}, .{0, -1}, .{0, 1}] {
            last_direction: Vector2_Int;
            if current.parent == null {
                last_direction = .{1, 0};
            } else {
                last_direction = .{
                    current.position.x - current.parent.position.x,
                    current.position.y - current.parent.position.y
                };
            }

            backwards: bool;
            if      last_direction == .{-1, 0} backwards = (it == .{1, 0});
            else if last_direction == .{1, 0}  backwards = (it == .{-1, 0});
            else if last_direction == .{0, -1} backwards = (it == .{0, 1});
            else if last_direction == .{0, 1}  backwards = (it == .{0, -1});

            new_cost := (
                current.cost + ifx last_direction == it then 1 else 1001
            );

            new_position := Vector2_Int.{
                current.position.x + it.x,
                current.position.y + it.y
            };

            new_state := Reindeer_State.{new_position, last_direction};
            seen_cost, success := table_find(*seen, new_state);

            // No need for bounds checking; the map is completely surrounded by
            // walls.
            if
                !map[new_position.y][new_position.x]
                && !backwards
                && (!success || seen_cost >= new_cost)
            {
                new := New(Node);
                memcpy(new, current, size_of(Node));

                new.parent = current;
                new.cost = new_cost;
                new.position = new_position;

                heap_add(*heap, new);
                table_set(*seen, new_state, new_cost);
            }
        }
    }

    places_to_sit: Table(
        Vector2_Int,
        void,
        (vector: Vector2_Int) -> u32 {
            return inline sdbm_hash(xx *vector, size_of(Vector2_Int));
        },
        #procedure_of_call(operator ==(Vector2_Int.{}, Vector2_Int.{}))
    );

    defer deinit(*places_to_sit);

    for best_paths {
        for it {
            if !table_contains(*places_to_sit, it) {
                table_add(*places_to_sit, it, #run {});
            }
        }
    }

    print("Part 2: %\n", places_to_sit.count);
}
