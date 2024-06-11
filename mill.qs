namespace QuantumMill {
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;

    // Define a type for the board (array of integers)
    newtype Board = Int[];

    // Define a type for a position on the board
    newtype Position = Int;

    // Define a type for a mill (a tuple of three positions)
    newtype Mill = (Position, Position, Position);

    // List of all possible mills on the board
   function PossibleMills() : (Int, Int, Int)[] {
    return [
        // Horizontal mills
        (0, 1, 2), (3, 4, 5), (6, 7, 8),
        (9, 10, 11), (12, 13, 14), (15, 16, 17),
        (18, 19, 20), (21, 22, 23),
        // Vertical mills
        (0, 9, 21), (3, 10, 18), (6, 11, 15),
        (1, 4, 7), (16, 19, 22), (8, 12, 17),
        (5, 13, 20), (2, 14, 23)
    ];
}

    // Check if a position is part of a mill

function IsPartOfMill(board : Qubit[], pos: Int, player : Result) : Bool {
    for (a, b, c) in PossibleMills() {
        if (pos == a or pos == b or pos == c) {
            // Measure qubits to check their values
            let valueA = M(board[a]); // Measure and reset to |0⟩ state
            Reset(board[a]); 
            let valueB = M(board[b]); // Measure and reset to |0⟩ state
            Reset(board[b]);
            let valueC = M(board[c]); // Measure and reset to |0⟩ state
            Reset(board[c]); 

            if (valueA == player and valueB == player and valueC == player) {
                return true; // Return true if a mill is found
            }
        }
    }
    return false; // Explicitly return false if no mill is found
}

// Check if a move creates a mill
function CreatesMill(board: Qubit[], player: Result, pos: Int) : Bool {
    return IsPartOfMill(board, pos, player);
}



// Remove an opponent's piece from the board
operation RemoveOpponentPiece(board: Qubit[], opponent: Result) : Int[] {
    mutable newBoard = [];
    mutable removed = false;

    // Copy the board into newBoard as integers
    for (i) in 0..Length(board) {
    set newBoard w/= i <- (M(board[i]) == opponent) ? 1 | 0; 
}

    // Attempt to remove a non-mill piece
    for (i) in 0..Length(board) - 1 {
        if newBoard[i] == 1 and not IsPartOfMill(board, i, opponent) {
            set newBoard w/= i <- 0;
            set removed = true;
            return newBoard; // Return immediately after removing a non-mill piece
        }
    }

    // If no non-mill pieces were found, remove a mill piece
    if not removed {
        for (i) in 0..Length(board) - 1 {
            if newBoard[i] == 1 {
                set newBoard w/= i <- 0;
                return newBoard; // Return immediately after removing a mill piece
            }
        }
    }

    return newBoard;
}

operation CountPieces(board : Int[], player : Int) : Int {
    mutable count = 0;
    for (position) in IndexRange(board) {
        if (board[position] == player) {
            set count += 1;
        }
    }
    return count;
}

    // Generate possible moves for a given player using superposition
    operation GeneratePossibleMovesUsingSuperposition(board: Int[], player: Int) : Qubit[] {
        // Determine the opponent player
        let opponent = player == 1 ? 2 | 1;

        // Find all possible moves
        mutable possibleMoves = [];

        // Count the number of pieces the player has
        let pieceCount = CountPieces(board, player);

        use qubits = Qubit[24];
        // Initialize qubits to superposition
        ApplyToEach(H, qubits);

            for (i) in 0..23 {
                // Measure each qubit to find possible empty positions
                if (M(qubits[i]) == Zero and board[i] == 0) {
                    // Create a copy of the board
                    mutable newBoard = board;

                    // Place the player's piece in the current position
                    set newBoard w/= i <- player;

                    // Check if this move creates a mill
                    if (CreatesMill(newBoard, player, i)) {
                        // Remove an opponent's piece if a mill is created
                        let boardAfterRemoval = RemoveOpponentPiece(newBoard, opponent);
                        set possibleMoves += [boardAfterRemoval];
                    } else {
                        // Append the new board state to possibleMoves
                        set possibleMoves += [newBoard];
                    }
                }
            }

            if (pieceCount <= 3) {
                // Player can move to any empty position if they have 3 or fewer pieces
                for (i in 0..23) {
                    if (board[i] == player) {
                        for (j in 0..23) {
                            if (board[j] == 0) {
                                // Create a copy of the board
                                mutable newBoard = board;
                                // Move the player's piece to the new position
                                set newBoard w/= i <- 0;
                                set newBoard w/= j <- player;

                                // Check if this move creates a mill
                                if (CreatesMill(newBoard, player, j)) {
                                    // Remove an opponent's piece if a mill is created
                                    let boardAfterRemoval = RemoveOpponentPiece(newBoard, opponent);
                                    set possibleMoves += [boardAfterRemoval];
                                } else {
                                    // Append the new board state to possibleMoves
                                    set possibleMoves += [newBoard];
                                }
                            }
                        }
                    }
                }
            }

            // Reset qubits to initial state
            ApplyToEach(Reset, qubits);
        }

        // Return the list of possible new board states
        return possibleMoves;
    }

    // Classical function to display the board
    function DisplayBoard(board: Board) : Unit {
        Message("Board:");
        let boardStr = "";
        for (i in 0..Length(board) - 1) {
            let piece = board[i];
            let pieceStr = if piece == 0 { "." } elif piece == 1 { "X" } else { "O" };
            boardStr += pieceStr + " ";
            if i == 2 or i == 6 or i == 9 or i == 13 or i == 16 or i == 20 or i == 23 {
                boardStr += "\n";
            } else if i == 3 or i == 10 or i == 17 {
                boardStr += "  ";
            }
        }
        Message(boardStr);
    }

    // Entry point to test the GeneratePossibleMovesUsingSuperposition operation
    @EntryPoint()
    operation Main() : Unit {
        // Initial empty board with 24 positions
        let board = Board([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

        // Generate and display moves for Player 1 (X)
        Message("Player 1 (X) possible moves using superposition:");
        let possibleMovesPlayer1 = GeneratePossibleMovesUsingSuperposition(board, 1);
        for (newBoard in possibleMovesPlayer1) {
            DisplayBoard(newBoard);
            Message("----------------");
        }

        // Simulate a move by Player 1 (placing an X at position 0)
        set board w/= 0 <- 1;

        // Generate and display moves for Player 2 (O)
        Message("Player 2 (O) possible moves using superposition:");
        let possibleMovesPlayer2 = GeneratePossibleMovesUsingSuperposition(board, 2);
        for (newBoard in possibleMovesPlayer2) {
            DisplayBoard(newBoard);
            Message("----------------");
        }
    }
}
