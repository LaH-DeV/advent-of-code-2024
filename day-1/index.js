import { join } from "path";
import { readFile } from "fs/promises";

/**
 * @param {number[]} left
 * @param {number[]} right
 * @returns {number} totalDistance
 */
function calculateTotalDistance(left, right) {
    return left.map((num, i) => Math.abs(num - right[i])).reduce((a, b) => a + b);
}

/**
 * @param {number[]} left
 * @param {number[]} right
 * @returns {number} similarityScore
 */
function calculateSimilarityScore(left, right) {
    const hash = new Map();
    for (let i = 0; i < right.length; i++) {
        hash.set(right[i], (hash.get(right[i]) ?? 0) + 1);
    }

    let similarityScore = 0;
    for (let i = 0; i < left.length; i++) {
        similarityScore = similarityScore + (left[i] * (hash.get(left[i]) ?? 0));
    }
    return similarityScore;
}

function main() {
    // assuming left.length === right.length
    readFile(join("day-1", "input.txt"), "utf-8").then(input => {
        const numbers = input.trim().split("\n").map((line) => line.trim().split(/\s+/).map(Number));

        let left = [];
        let right = [];
        for (let i = 0; i < numbers.length; i++) {
            left.push(numbers[i][0]);
            right.push(numbers[i][1]);
        }
        [left, right] = [left, right].map(arr => arr.sort((a, b) => a - b));

        const totalDistance = calculateTotalDistance(left, right);
        console.log({ partOne: totalDistance });

        const similarityScore = calculateSimilarityScore(left, right);
        console.log({ partTwo: similarityScore });

    }).catch(err => console.error(err));
}

main();