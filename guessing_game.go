package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"
)

func main() {
	// Seed the random number generator
	rand.Seed(time.Now().UnixNano())
	secretNumber := rand.Intn(100) + 1 // Random number between 1 and 100
	attempts := 7                      // Maximum number of attempts

	fmt.Println("Welcome to the Number Guessing Game!")
	fmt.Println("I have chosen a number between 1 and 100.")
	fmt.Printf("You have %d attempts to guess it. Good luck!\n\n", attempts)

	reader := bufio.NewReader(os.Stdin)

	for attempts > 0 {
		fmt.Printf("Enter your guess (%d attempts remaining): ", attempts)
		input, _ := reader.ReadString('\n')
		input = strings.TrimSpace(input)
		guess, err := strconv.Atoi(input)

		if err != nil {
			fmt.Println("Invalid input. Please enter a valid number.")
			continue
		}

		if guess < 1 || guess > 100 {
			fmt.Println("Please guess a number between 1 and 100.")
			continue
		}

		if guess < secretNumber {
			fmt.Println("Too low!")
		} else if guess > secretNumber {
			fmt.Println("Too high!")
		} else {
			fmt.Printf("Congratulations! You guessed the number %d correctly!\n", secretNumber)
			return
		}

		attempts--
	}

	fmt.Printf("Sorry, you've used all your attempts. The number was %d.\n", secretNumber)
}
