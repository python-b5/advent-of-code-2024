/* Advent of Code 2024
 * Day 15: Warehouse Woes
 */

#import "Basic";
#import "File";
#import "String";

Tile :: enum {
    EMPTY;
    WALL;
    BOX;
    BOX_LEFT;
    BOX_RIGHT;
}

Vector2_Int :: struct {
    x, y: int;
}

array_free_2d :: (array: [..][..] $T) {
    for array {
        array_free(it);
    }

    array_free(array);
}

is_box :: inline (tile: Tile) -> bool {
    return tile == .BOX || tile == .BOX_LEFT || tile == .BOX_RIGHT;
}

// Moves a box in a given direction. Does not perform any validity checks; that
// is all handled by push_box(). The inputs to this procedure are assumed to be
// valid.
move_box :: inline (
    map: [..][..] Tile,
    position: Vector2_Int,
    direction: Vector2_Int
) {
    tile := map[position.y][position.x];
    map[position.y][position.x] = .EMPTY;
    map[position.y + direction.y][position.x + direction.x] = tile;
}

// Attempts to push a box in a given direction, along with all boxes in its way.
// Returns whether the push was successful.
//
// If should_push is false, the procedure will return whether the push is
// possible, but will not actually move the boxes. This is necessary for part 2,
// where we have to check whether multiple pushes are possible before pushing
// some boxes (and thus don't want a possible push to still physically happen if
// the other push isn't possible).
push_box :: (
    map: [..][..] Tile,
    position: Vector2_Int,
    direction: Vector2_Int,
    should_push := true
) -> bool {
    tile := map[position.y][position.x];
    if direction.x == 0 && (tile == .BOX_LEFT || tile == .BOX_RIGHT) {
        other_side := ifx tile == .BOX_LEFT then 1 else -1;
        next_tile_1 := map[position.y + direction.y][position.x];
        next_tile_2 := map[position.y + direction.y][position.x + other_side];

        aligned_with_next_box := (
            tile == .BOX_LEFT && next_tile_1 == .BOX_LEFT
            || tile == .BOX_RIGHT && next_tile_2 == .BOX_LEFT
        );

        if
            aligned_with_next_box && push_box(map, .{
                position.x + ifx tile == .BOX_RIGHT then -1 else 0,
                position.y + direction.y
            }, direction, false)
            || (
                next_tile_1 == .EMPTY || is_box(next_tile_1) && push_box(map, .{
                    position.x,
                    position.y + direction.y
                }, direction, false)
            ) && (
                next_tile_2 == .EMPTY || is_box(next_tile_2) && push_box(map, .{
                    position.x + other_side,
                    position.y + direction.y
                }, direction, false)
            )
        {
            if should_push {
                // I'm not a huge fan of calling push_box() a second time here,
                // but without writing a separate can_push_box() procedure for
                // above (which would heavily complicate things), I don't think
                // there's a way around it. Either way, there are no performance
                // issues in the current version of the program, so it luckily
                // doesn't seem like much of a problem.
                if aligned_with_next_box {
                    push_box(map, .{
                        position.x + ifx tile == .BOX_RIGHT then -1 else 0,
                        position.y + direction.y
                    }, direction);
                } else {
                    if next_tile_1 != .EMPTY {
                        push_box(map, .{
                            position.x,
                            position.y + direction.y
                        }, direction);
                    }

                    if next_tile_2 != .EMPTY {
                        push_box(map, .{
                            position.x + other_side,
                            position.y + direction.y
                        }, direction);
                    }
                }

                move_box(map, position, direction);
                move_box(map, .{position.x + other_side, position.y}, direction);
            }

            return true;
        }
    } else {
        next_tile := map[position.y + direction.y][position.x + direction.x];
        if next_tile == .EMPTY || is_box(next_tile) && push_box(map, .{
            position.x + direction.x,
            position.y + direction.y
        }, direction, should_push) {
            if should_push {
                move_box(map, position, direction);
            }

            return true;
        }
    }

    return false;
}

// Performs a series of instructions on a robot in a warehouse, then calculates
// the sum of the GPS coordinates of the boxes in the warehouse after the robot
// has finished moving.
//
// We don't have to bother with bounds checking, because the warehouse is
// surrounded on all sides with walls.
get_gps_sum :: (
    map: [][..] Tile,
    robot: Vector2_Int,
    instructions: [] Vector2_Int
) -> int {
    // The map and robot parameters are immutable (since we don't want to modify
    // them outside this function), so since we need to be able to modify them
    // in this function, we thus need to make copies of them.
    mutable_map: [..][..] Tile;
    defer array_free_2d(mutable_map);

    for map {
        row: [..] Tile;
        array_copy(*row, it);
        array_add(*mutable_map, row);
    }

    mutable_robot := Vector2_Int.{robot.x, robot.y};

    for instructions {
        new_position := Vector2_Int.{
            mutable_robot.x + it.x,
            mutable_robot.y + it.y
        };

        new_tile := mutable_map[new_position.y][new_position.x];
        if new_tile == .EMPTY || is_box(new_tile) && push_box(
            mutable_map,
            new_position,
            it
        ) {
            mutable_robot = new_position;
        }
    }

    gps_sum := 0;
    for row, y: mutable_map {
        for tile, x: row {
            if tile == .BOX || tile == .BOX_LEFT {
                gps_sum += x + y * 100;
            }
        }
    }

    return gps_sum;
}

main :: () {
    input, success := read_entire_file("inputs/day_15.txt");
    assert(success);

    groups := split(input, "\n\n");
    defer array_free(groups);

    map_lines := split(groups[0], "\n");
    defer array_free(map_lines);

    map: [..][..] Tile;
    defer array_free_2d(map);

    robot: Vector2_Int;
    for line, y: map_lines {
        row: [..] Tile;
        for char, x: line {
            if char == {
                case #char "@"; robot = .{x, y}; #through;
                case #char "."; array_add(*row, .EMPTY);
                case #char "#"; array_add(*row, .WALL);
                case #char "O"; array_add(*row, .BOX);
            }
        }

        array_add(*map, row);
    }

    instructions: [..] Vector2_Int;
    defer array_free(instructions);

    for groups[1] {
        if it == {
            case #char "<"; array_add(*instructions, .{-1, 0});
            case #char ">"; array_add(*instructions, .{1, 0});
            case #char "^"; array_add(*instructions, .{0, -1});
            case #char "v"; array_add(*instructions, .{0, 1});
        }
    }

    print("Part 1: %\n", get_gps_sum(map, robot, instructions));

    wide_map: [..][..] Tile;
    defer array_free_2d(wide_map);

    for map {
        row: [..] Tile;
        for it {
            if it == .BOX {
                array_add(*row, .BOX_LEFT);
                array_add(*row, .BOX_RIGHT);
            } else {
                array_add(*row, it);
                array_add(*row, it);
            }
        }

        array_add(*wide_map, row);
    }

    robot.x *= 2;
    print("Part 2: %\n", get_gps_sum(wide_map, robot, instructions));
}
