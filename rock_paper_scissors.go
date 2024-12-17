package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strings"
	"time"
)

func main() {
	// Seed random number generator
	rand.Seed(time.Now().UnixNano())
	options := []string{"rock", "paper", "scissors"}

	fmt.Println("Welcome to Rock, Paper, Scissors!")
	fmt.Println("Type 'rock', 'paper', or 'scissors' to play. Type 'quit' to exit.")

	reader := bufio.NewReader(os.Stdin)

	for {
		// Get user's choice
		fmt.Print("\nEnter your choice: ")
		userInput, _ := reader.ReadString('\n')
		userInput = strings.TrimSpace(strings.ToLower(userInput))

		// Check if user wants to quit
		if userInput == "quit" {
			fmt.Println("Thanks for playing! Goodbye!")
			break
		}

		// Validate user's input
		if userInput != "rock" && userInput != "paper" && userInput != "scissors" {
			fmt.Println("Invalid input. Please choose 'rock', 'paper', or 'scissors'.")
			continue
		}

		// Generate computer's choice
		computerChoice := options[rand.Intn(len(options))]
		fmt.Printf("Computer chose: %s\n", computerChoice)

		// Determine the winner
		if userInput == computerChoice {
			fmt.Println("It's a tie!")
		} else if (userInput == "rock" && computerChoice == "scissors") ||
			(userInput == "scissors" && computerChoice == "paper") ||
			(userInput == "paper" && computerChoice == "rock") {
			fmt.Println("You win!")
		} else {
			fmt.Println("You lose!")
		}
	}
}
