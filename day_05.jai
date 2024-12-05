/* Advent of Code 2024
 * Day 05: Print Queue
 */

#import "Basic";
#import "File";
#import "Hash_Table";
#import "Sort";
#import "String";

// I'm not sure how to make page_compare() work without this being global.
ordering_rules: [..][2] int;

// The ordering rules map nicely to a comparison procedure. It feels really
// inefficient to iterate through the whole rules array for every comparison,
// but I'm not sure how else it could be done.
page_compare :: (a: int, b: int) -> int {
    for ordering_rules {
        if it[0] == a && it[1] == b {
            return -1;
        } else if it[0] == b && it[1] == a {
            return 1;
        }
    }

    return 0;
}

main :: () {
    input, success := read_entire_file("inputs/day_05.txt");
    assert(success);

    read_all_rules := false;
    correct_middle_page_sum := 0;
    incorrect_middle_page_sum := 0;

    for split(input, "\n") {
        // The two parts of the input are separated by a blank line. As usual,
        // we need to ignore the trailing newline if one exists in the input,
        // but this time we can't ignore the first one.
        if it == "" {
            if read_all_rules {
                continue;
            } else {
                read_all_rules = true;
            }
        }

        if !read_all_rules {
            pages := split(it, "|");
            array_add(
                *ordering_rules,
                .[string_to_int(pages[0]), string_to_int(pages[1])]
            );

            continue;
        }

        pages: [..] int;
        page_indices: Table(int, int);

        for split(it, ",") {
            page := string_to_int(it);
            array_add(*pages, page);
            table_add(*page_indices, page, it_index);
        }

        correctly_ordered := true;
        for ordering_rules {
            first_index,  found_first  := table_find(*page_indices, it[0]);
            second_index, found_second := table_find(*page_indices, it[1]);

            if found_first && found_second && first_index > second_index {
                correctly_ordered = false;
                break;
            }
        }

        if correctly_ordered {
            correct_middle_page_sum += pages[pages.count / 2];
        } else {
            sorted_pages := quick_sort(pages, page_compare);
            incorrect_middle_page_sum += sorted_pages[sorted_pages.count / 2];
        }
    }

    print(
        "Part 1: %\nPart 2: %\n",
        correct_middle_page_sum,
        incorrect_middle_page_sum
    );
}
