const card = @import("card.zig");
const deck = @import("deck.zig");
const std = @import("std");

/// A matrix of cards arranged in rows and columns.
pub const CardMatrix = struct {
    matrix: std.ArrayList(deck.CardList),
    allocator: std.mem.Allocator,

    /// Initializes and returns a matrix of cards.
    pub fn init(gpa: std.mem.Allocator, columns: usize, cardsPerDeck: usize) !CardMatrix {
        var new_matrix = CardMatrix{ .matrix = try std.ArrayList(deck.CardList).initCapacity(gpa, 20), .allocator = gpa };
        var new_deck: deck.CardList = undefined;

        // add a deck to each "column"
        for (0..columns) |_| {
            new_deck = try deck.CardList.init(gpa, cardsPerDeck);
            try new_matrix.matrix.append(gpa, new_deck);
        }

        return new_matrix;
    }

    /// Releases all memory.
    pub fn deinit(self: *CardMatrix) void {
        for (self.matrix.items) |*currentDeck| {
            currentDeck.deinit();
        }

        self.matrix.deinit(self.allocator);
    }

    /// Returns the amount of card in a specified column.
    pub fn columnSize(self: *CardMatrix, column: usize) usize {
        return self.matrix.items[column].cards.items.len;
    }

    /// Resets the entire matrix.
    pub fn reset(self: *CardMatrix) void {
        for (self.matrix.items) |cardDeck| {
            cardDeck.clear();
        }
    }

    /// Adds a card to the specified row.
    pub fn addCard(self: *CardMatrix, column: u8, newCard: card.Identity) !void {
        try self.matrix.items[column].addCard(newCard);
    }

    /// Removes the last card from the specified row.
    pub fn removeCard(self: *CardMatrix, column: u8) ?card.Identity {
        return self.matrix.items[column].removeCardByIndex(self.matrix.items[column].cards.items.len - 1);
    }

    /// Returns the card at the given row and column.
    pub fn lookUp(self: *CardMatrix, column: u8, row: u8) ?card.Identity {
        return self.matrix.items[column].lookUpByIndex(row);
    }

    /// Clears a column.
    pub fn clearColumn(self: *CardMatrix, column: usize) void {
        self.matrix.items[column].clear();
    }
};
