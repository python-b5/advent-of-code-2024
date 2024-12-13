/* Advent of Code 2024
 * Day 13: Claw Contraption
 */

#import "Basic";
#import "File";
#import "String";

Machine :: struct {
    // No reason to define Vector2_Int when we're only using it here. An
    // anonymous struct works just fine.
    button_a, button_b, prize: struct {
        x, y: int;
    };
}

get_token_cost :: (machines: [] Machine, limit_button_presses: bool) -> int {
    tokens := 0;
    for machines {
        // Saves some typing.
        button_a := it.button_a;
        button_b := it.button_b;
        prize := it.prize;

        determinant := button_a.x * button_b.y - button_b.x * button_a.y;

        a_presses := (
            button_b.y * prize.x - button_b.x * prize.y
        ) / determinant;

        b_presses := (
            button_a.x * prize.y - button_a.y * prize.x
        ) / determinant;

        if
            button_a.x * a_presses + button_b.x * b_presses == prize.x
            && button_a.y * a_presses + button_b.y * b_presses == prize.y
            && a_presses > 0 && b_presses > 0
            && (!limit_button_presses || a_presses <= 100 && b_presses <= 100)
        {
            tokens += a_presses * 3 + b_presses;
        }
    }

    return tokens;
}

main :: () {
    input, success := read_entire_file("inputs/day_13.txt");
    assert(success);

    groups := split(input, "\n\n");
    defer array_free(groups);

    machines: [..] Machine;
    defer array_free(machines);

    for groups {
        // Conveniently, this approach means we don't have to worry about the
        // trailing newline at all; it's ignored automatically.
        lines := split(it, "\n");
        defer array_free(lines);

        button_a := split(slice(lines[0], 12, lines[0].count - 12), ", Y+");
        button_b := split(slice(lines[1], 12, lines[1].count - 12), ", Y+");
        prize := split(slice(lines[2], 9, lines[2].count - 9), ", Y=");
        defer array_free(button_a);
        defer array_free(button_b);
        defer array_free(prize);

        array_add(*machines, Machine.{
            .{string_to_int(button_a[0]), string_to_int(button_a[1])},
            .{string_to_int(button_b[0]), string_to_int(button_b[1])},
            .{string_to_int(prize[0]), string_to_int(prize[1])},
        });
    }

    print("Part 1: %\n", get_token_cost(machines, true));

    for *machines {
        it.prize.x += 10000000000000;
        it.prize.y += 10000000000000;
    }

    print("Part 2: %\n", get_token_cost(machines, false));
}
