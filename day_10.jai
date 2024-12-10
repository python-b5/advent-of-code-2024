/* Advent of Code 2024
 * Day 10: Hoof It
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
    input, success := read_entire_file("inputs/day_10.txt");
    assert(success);

    map: [..][..] int;
    defer {
        for map {
            array_free(it);
        }

        array_free(map);
    }

    trailheads: [..] Vector2_Int;
    defer array_free(trailheads);

    for line, y: split(input, "\n") {
        if line == "" {
            continue;
        }

        row: [..] int;
        for char, x: line {
            array_add(*row, char - #char "0");

            if char == #char "0" {
                array_add(*trailheads, .{x, y});
            }
        }

        array_add(*map, row);
    }

    width := map[0].count;
    height := map.count;

    score_sum := 0;
    rating_sum := 0;

    for trailheads {
        trails: [..][..] Vector2_Int;
        defer array_free(trails);

        trail: [..] Vector2_Int;
        array_add(*trail, it);
        array_add(*trails, trail);

        reachable_peaks: Vector2_Int_Set;
        defer deinit(*reachable_peaks);

        while trails.count {
            trail := pop(*trails);
            defer array_free(trail);

            tile := trail[trail.count - 1];
            current_height := map[tile.y][tile.x];

            for Vector2_Int.[
                .{tile.x - 1, tile.y},
                .{tile.x + 1, tile.y},
                .{tile.x, tile.y - 1},
                .{tile.x, tile.y + 1}
            ] {
                if
                    it.x >= 0 && it.x < width && it.y >= 0 && it.y < height
                    && map[it.y][it.x] == current_height + 1
                {
                    if map[it.y][it.x] == 9 {
                        if !table_contains(*reachable_peaks, it) {
                            table_add(*reachable_peaks, it, #run {});
                        }

                        rating_sum += 1;
                    } else {
                        new_trail: [..] Vector2_Int;
                        array_copy(*new_trail, trail);
                        array_add(*new_trail, it);
                        array_add(*trails, new_trail);
                    }
                }
            }
        }

        score_sum += reachable_peaks.count;
    }

    print("Part 1: %\nPart 2: %\n", score_sum, rating_sum);
}
