/* Advent of Code 2024
 * Day 21: Keypad Conundrum
 */

#import "Basic";
#import "File";
#import "Hash";
#import "Hash_Table";
#import "Math";
#import "String";

Vector2_Int :: struct {
    x, y: int;
}

State :: struct {
    code: string;
    depth: int;
}

Button_Table :: Table(u8, Vector2_Int);

Path_Table :: Table(
    [2] u8,
    [..] u8,
    given_compare_function = (a: [2] u8, b: [2] u8) -> bool {
        return a[0] == b[0] && a[1] == b[1];
    }
);

Length_Table :: Table(
    State,
    int,
    (state: State) -> u32 {
        return inline sdbm_hash(xx *state, size_of(State));
    },
    (a: State, b: State) -> bool {
        return a.code == b.code && a.depth == b.depth;
    }
);

operator == :: inline (a: Vector2_Int, b: Vector2_Int) -> bool {
    return a.x == b.x && a.y == b.y;
}

sign :: inline (n: int) -> int {
    if n < 0 return -1;
    if n > 0 return 1;
    return 0;
}

get_path :: (
    start: Vector2_Int,
    end: Vector2_Int,
    gap: Vector2_Int
) -> [..] u8 {
    path: [..] u8;

    if start != end {
        char_x: u8 = xx (
            ifx sign(end.x - start.x) == -1 then #char "<" else #char ">"
        );

        char_y: u8 = xx (
            ifx sign(end.y - start.y) == -1 then #char "^" else #char "v"
        );

        // This is a little convoluted, but makes sure we're using the correct
        // direction priorities.
        if char_x == #char "<" {
            if Vector2_Int.{end.x, start.y} == gap {
                for 1..abs(end.y - start.y) array_add(*path, char_y);
                for 1..abs(end.x - start.x) array_add(*path, char_x);
            } else {
                for 1..abs(end.x - start.x) array_add(*path, char_x);
                for 1..abs(end.y - start.y) array_add(*path, char_y);
            }
        } else if Vector2_Int.{start.x, end.y} == gap {
            for 1..abs(end.x - start.x) array_add(*path, char_x);
            for 1..abs(end.y - start.y) array_add(*path, char_y);
        } else {
            for 1..abs(end.y - start.y) array_add(*path, char_y);
            for 1..abs(end.x - start.x) array_add(*path, char_x);
        }
    }

    array_add(*path, #char "A");
    return path;
}

get_paths :: (buttons: Button_Table, gap: Vector2_Int) -> Path_Table {
    paths: Path_Table;
    for first_position, first: buttons {
        for second_position, second: buttons {
            table_add(*paths, .[first, second], get_path(
                first_position,
                second_position,
                gap
            ));
        }
    }

    return paths;
}

free_paths :: (paths: *Path_Table) {
    for paths {
        array_free(it);
    }

    deinit(paths);
}

get_sequence :: (code: string, depth: int, paths: *Path_Table) -> string {
    sequence: [..] u8;
    previous: u8 = #char "A";

    for 0..code.count - 1 {
        path, _ := table_find(paths, .[previous, code[it]]);
        array_add(*sequence, .. path);
        previous = code[it];
    }

    return xx sequence;
}

get_sequence_length :: (
    code: string,
    depth: int,
    paths: *Path_Table,
    known_lengths: *Length_Table
) -> int {
    state := State.{code, depth};
    known_length, success := table_find(known_lengths, state);

    if success {
        return known_length;
    }

    length := 0;
    previous: u8 = #char "A";

    for code {
        path, _ := table_find(paths, .[previous, it]);

        if depth > 1 {
            length += get_sequence_length(
                xx path,
                depth - 1,
                paths,
                known_lengths
            );
        } else {
            length += path.count;
        }

        previous = it;
    }

    table_add(known_lengths, state, length);
    return length;
}

main :: () {
    input, success := read_entire_file("inputs/day_21.txt");
    assert(success);

    codes := split(input, "\n");
    pop(*codes);
    defer array_free(codes);

    // Might as well run all this at compile time. These don't change based on
    // the input.
    numeric_buttons :: #run () -> Button_Table {
        buttons: Button_Table;
        table_add(*buttons, #char "0", .{1, 3});
        table_add(*buttons, #char "1", .{0, 2});
        table_add(*buttons, #char "2", .{1, 2});
        table_add(*buttons, #char "3", .{2, 2});
        table_add(*buttons, #char "4", .{0, 1});
        table_add(*buttons, #char "5", .{1, 1});
        table_add(*buttons, #char "6", .{2, 1});
        table_add(*buttons, #char "7", .{0, 0});
        table_add(*buttons, #char "8", .{1, 0});
        table_add(*buttons, #char "9", .{2, 0});
        table_add(*buttons, #char "A", .{2, 3});

        return buttons;
    }();

    directional_buttons :: #run () -> Button_Table {
        buttons: Button_Table;
        table_add(*buttons, #char "<", .{0, 1});
        table_add(*buttons, #char ">", .{2, 1});
        table_add(*buttons, #char "^", .{1, 0});
        table_add(*buttons, #char "v", .{1, 1});
        table_add(*buttons, #char "A", .{2, 0});

        return buttons;
    }();

    numeric_gap :: Vector2_Int.{0, 3};
    directional_gap :: Vector2_Int.{0, 0};

    numeric_paths := get_paths(numeric_buttons, numeric_gap);
    directional_paths := get_paths(directional_buttons, directional_gap);
    defer free_paths(*numeric_paths);
    defer free_paths(*directional_paths);

    directional_start :: Vector2_Int.{2, 0};

    complexity_sum_part_1 := 0;
    complexity_sum_part_2 := 0;

    known_lengths: Length_Table;
    defer deinit(*known_lengths);

    for codes {
        // I don't think there's a way around generating the actual sequence for
        // the robot using the numeric keypad - at least, not without massively
        // complicating the get_sequence_length() procedure by adding the
        // numeric keypad as a base case. Besides, doing it this way means we
        // only need to find the sequence once.
        first_sequence := get_sequence(it, 0, *numeric_paths);
        numeric_part := string_to_int(slice(it, 0, 3));

        complexity_sum_part_1 += get_sequence_length(
            first_sequence,
            2,
            *directional_paths,
            *known_lengths
        ) * numeric_part;

        complexity_sum_part_2 += get_sequence_length(
            first_sequence,
            25,
            *directional_paths,
            *known_lengths
        ) * numeric_part;
    }

    print(
        "Part 1: %\nPart 2: %\n",
        complexity_sum_part_1,
        complexity_sum_part_2
    );
}
