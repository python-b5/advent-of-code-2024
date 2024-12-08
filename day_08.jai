/* Advent of Code 2024
 * Day 08: Resonant Collinearity
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

// Finds all valid antinodes, moving outwards from an antenna. This is called
// twice for each antenna pair.
find_antinodes :: (
    antenna: Vector2_Int,
    slope: Vector2_Int,
    width: int,
    height: int
) -> [] Vector2_Int {
    antinode := antenna;
    antinodes: [..] Vector2_Int;

    while true {
        array_add(*antinodes, antinode);

        antinode.x += slope.x;
        antinode.y += slope.y;

        if
            antinode.x < 0 || antinode.x >= width
            || antinode.y < 0 || antinode.y >= height
        {
            break;
        }
    }

    return antinodes;
}

// Adds the current antinode in a for loop to the correct tables. Saves some
// repetition lower down.
add_antinode :: () #expand {
    // The first antinode is on the antenna itself, so the second one is what is
    // relevant for part 1.
    if `it_index == 1 && !table_contains(*`antinodes_part_1, `it) {
        table_add(*`antinodes_part_1, `it, #run {});
    }

    if !table_contains(*`antinodes_part_2, `it) {
        table_add(*`antinodes_part_2, `it, #run {});
    }
}

main :: () {
    input, success := read_entire_file("inputs/day_08.txt");
    assert(success);

    lines := split(input, "\n");
    width := lines[0].count;
    height := lines.count - 1;

    antennas: Table(u8, [..] Vector2_Int);
    for line, y: lines {
        if line == "" {
            continue;
        }

        for char, x: line {
            if char == #char "." {
                continue;
            }

            antenna_group := table_find_pointer(*antennas, char);
            if antenna_group == null {
                new_group: [..] Vector2_Int;
                table_add(*antennas, char, new_group);
                antenna_group = table_find_pointer(*antennas, char);
            }

            array_add(antenna_group, .{x, y});
        }
    }

    antinodes_part_1, antinodes_part_2: Vector2_Int_Set;
    for antenna_group: antennas {
        for index_1: 0..antenna_group.count - 1 {
            for index_2: 0..antenna_group.count - 1 {
                if index_2 == index_1 {
                    continue;
                }

                antenna_1 := antenna_group[index_1];
                antenna_2 := antenna_group[index_2];

                for find_antinodes(
                    antenna_1,
                    .{antenna_1.x - antenna_2.x, antenna_1.y - antenna_2.y},
                    width,
                    height
                ) {
                    add_antinode();
                }

                for find_antinodes(
                    antenna_2,
                    .{antenna_2.x - antenna_1.x, antenna_2.y - antenna_1.y},
                    width,
                    height
                ) {
                    add_antinode();
                }
            }
        }

        array_free(antenna_group);
    }

    print(
        "Part 1: %\nPart 2: %\n",
        antinodes_part_1.count,
        antinodes_part_2.count
    );
}
