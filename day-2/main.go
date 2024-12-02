package main

import (
	"log"
	"os"
	"strconv"
	"strings"
)

func main() {
	input, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatalf(err.Error())
	}
	safeLevels := 0
	for _, line := range strings.Split(string(input), "\n") {
		digits := strings.Split(strings.TrimSpace(line), " ")
		if isLineSafe(digits) {
			safeLevels += 1
		}
	}
	log.Printf(":: 1 > Safe levels: %d \n", safeLevels)

	safeLevels = 0
	for _, line := range strings.Split(string(input), "\n") {
		digits := strings.Split(strings.TrimSpace(line), " ")
		if isLineSafe(digits) {
			safeLevels += 1
			continue
		}
	inner:
		for index := range digits {
			newDigits := removeOneElement(digits, index)
			if isLineSafe(newDigits) {
				safeLevels += 1
				break inner
			}
		}
	}
	log.Printf(":: 2 > Safe levels with Problem Dampener: %d \n", safeLevels)
}

func isLineSafe(digits []string) bool {
	previousNum := 0
	direction := 0
	for index, digit := range digits {
		num, _ := strconv.Atoi(digit) // ignoring error
		if index == 0 {
			previousNum = num
			continue
		}
		if index == 1 {
			direction = getDirection(num, previousNum)
		}
		difference := abs(num - previousNum)
		currentDirection := getDirection(num, previousNum)
		previousNum = num
		if !(difference > 0 && difference < 4) || (direction != currentDirection) {
			return false
		}
	}
	return true
}

func removeOneElement(digits []string, index int) []string {
	newDigits := make([]string, 0)
	for i, digit := range digits {
		if i == index {
			continue
		}
		newDigits = append(newDigits, digit)
	}
	return newDigits
}

func getDirection(num, previousNum int) int {
	if num > previousNum {
		return 1
	} else {
		return -1
	}
}

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}
