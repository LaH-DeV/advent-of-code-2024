<?php
function read_rules_and_updates($filename) {
	$lines = explode("\n", file_get_contents($filename));
	$rules = [];
	$updates = [];
	foreach ($lines as $line) {
		if (str_contains($line, "|")) {
			$rule = explode("|", $line);
			$rules["$rule[0]|$rule[1]"] = true;
		} else if (str_contains($line, ",")) {
			$updates[] = explode(",", $line);
		}
	}
	return [$rules, $updates];
}

function find_rule_for_update($rs, $update, $i, $j) {
	if ($j >= count($update) || $i == $j) return null;
	if (isset($rs["$update[$i]|$update[$j]"])) {
		return [$update[$i], $update[$j]];
	} else if (isset($rs["$update[$j]|$update[$i]"])) {
		return [$update[$j], $update[$i]];
	}
	return null;
}

function is_update_correct($rules, $update, &$cache) {
	$update_str = implode(",", $update);
	if (isset($cache[$update_str])) return $cache[$update_str];
	for ($i = 0; $i < count($update) - 1; $i++) {
		for ($j = $i + 1; $j < count($update); $j++) {
			$rule = find_rule_for_update($rules, $update, $i, $j);
			if ($rule === null || $rule[0] !== $update[$i] || $rule[1] !== $update[$j]) {
				$cache[$update_str] = false;
				return false;
			}
		}
	}
	$cache[$update_str] = true;
	return true;
}

function reorder_update($rules, $update, &$cache) {
	$update_str = implode(",", $update);
	if (isset($cache[$update_str]) && $cache[$update_str]) return $update;
	$new_update = $update;
	$swapped = true;
	while ($swapped) {
		$swapped = false;
		for ($i = 0; $i < count($new_update) - 1; $i++) {
			for ($j = $i + 1; $j < count($new_update); $j++) {
				$rule = find_rule_for_update($rules, $new_update, $i, $j);
				if ($rule === null) continue;
				if ($rule[0] != $new_update[$i] || $rule[1] != $new_update[$j]) {
					$temp = $new_update[$i];
					$new_update[$i] = $new_update[$j];
					$new_update[$j] = $temp;
					$swapped = true;
					break;
				}
			}
			if ($swapped) break;
		}
	}
	$cache[$update_str] = true;
	return $new_update;
}

function part_one($rules, $updates) {
	$sum = 0;
	$cache = [];
	foreach ($updates as $update) {
		if (is_update_correct($rules, $update, $cache)) {
			$sum += $update[floor(count($update) / 2)];
		}
	}
	return $sum;
}

function part_two($rules, $updates) {
	$sum = 0;
	$cache = [];
	foreach ($updates as $update_index=>$update) {
		if (is_update_correct($rules, $update, $cache)) continue;
		$new_update = reorder_update($rules, $update, $cache);
		$sum += $new_update[floor(count($new_update) / 2)];
	}
	return $sum;
}

function main() {
	[$rules, $updates] = read_rules_and_updates("input.txt");

	echo "Part one: " . part_one($rules, $updates) . "\n";
	echo "Part two: " . part_two($rules, $updates) . "\n";
}
// Part one: 5964
// Part two: 4719
main();
?>
