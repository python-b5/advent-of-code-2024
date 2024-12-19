/* Advent of Code 2024
 * Day 19: Linen Layout
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "String";

get_solution :: (
    design: string,
    towels: [] string,
    known_solutions: *Table(string, int)
) -> int {
    known_solution, success := table_find(known_solutions, design);
    if success {
        return known_solution;
    }

    solution := 0;
    for towels {
        if design == it {
            solution += 1;
        } else if begins_with(design, it) {
            solution += get_solution(
                slice(design, it.count, design.count - it.count),
                towels,
                known_solutions
            );
        }
    }

    table_add(known_solutions, design, solution);
    return solution;
}

main :: () {
    input, success := read_entire_file("inputs/day_19.txt");
    assert(success);

    lines := split(input, "\n");
    defer array_free(lines);

    towels := split(lines[0], ", ");
    defer array_free(towels);

    designs := array_view(lines, 2, lines.count - 3);

    // I didn't want this to be global, so I'm passing a pointer to it into the
    // get_solutions() procedure.
    known_solutions: Table(string, int);
    deinit(*known_solutions);

    possible_designs := 0;
    total_solutions := 0;

    for designs {
        solutions := get_solution(it, towels, *known_solutions);

        if solutions > 0 {
            possible_designs += 1;
        }

        total_solutions += solutions;
    }

    print("Part 1: %\nPart 2: %\n", possible_designs, total_solutions);
}
