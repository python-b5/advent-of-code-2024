/* Advent of Code 2024
 * Day 02: Red-Nosed Reports
 */

#import "Basic";
#import "File";
#import "Math";
#import "String";

sign :: (n: int) -> int {
    if n > 0 return 1;
    if n < 0 return -1;
    return 0;
}

is_report_safe :: (report: [] int) -> bool {
    difference_sign := 0;
    for 1..report.count - 1 {
        difference := report[it] - report[it - 1];

        if difference_sign == 0 {
            difference_sign = sign(difference);
        } else if sign(difference) != difference_sign {
            return false;
        }

        if abs(difference) < 1 || abs(difference) > 3 {
            return false;
        }
    }

    return true;
}

main :: () {
    input, success := read_entire_file("inputs/day_02.txt");
    assert(success);

    reports: [..][..] int;
    for split(input, "\n") {
        if it == "" {
            continue;
        }

        report: [..] int;
        for split(it, " ") {
            array_add(*report, string_to_int(it));
        }

        array_add(*reports, report);
    }

    safe_reports := 0;
    mostly_safe_reports := 0;

    for report: reports {
        if is_report_safe(report) {
            safe_reports += 1;
            mostly_safe_reports += 1;
        } else {
            for 0..report.count - 1 {
                modified_report := array_copy(report);
                array_ordered_remove_by_index(*modified_report, it);

                if is_report_safe(modified_report) {
                    mostly_safe_reports += 1;
                    break;
                }
            }
        }
    }

    print("Part 1: %\nPart 2: %\n", safe_reports, mostly_safe_reports);
}
