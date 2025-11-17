//! Provides a struct for a card matrix.
const Card = @import("card.zig");
const Deck = @import("deck.zig");
const std = @import("std");

pub const CardMatrix = @This();

/// An ArrayList of CardList, you can handle this manually for more control over the decks that form the matrix.
matrix: std.ArrayList(Deck),

/// The allocator used by this struct.
allocator: std.mem.Allocator,

/// Initializes and returns a matrix of cards.
pub fn init(gpa: std.mem.Allocator, columns: u16, rows: u16) !CardMatrix {
    var new_matrix = CardMatrix{ .matrix = try std.ArrayList(Deck).initCapacity(gpa, 20), .allocator = gpa };
    var new_deck: Deck = undefined;

    // add a deck to each "column"
    for (0..columns) |_| {
        new_deck = try Deck.init(gpa, rows);
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

/// Returns the amount of cards in a specified column.
pub fn columnSize(self: *CardMatrix, column_index: usize) usize {
    return self.matrix.items[column_index].cards.items.len;
}

/// Resets the entire matrix.
pub fn reset(self: *CardMatrix) void {
    for (self.matrix.items) |*cardDeck| {
        cardDeck.clear();
    }
}

/// Adds a card to the specified row.
pub fn addCard(self: *CardMatrix, column_index: usize, newCard: Card) !void {
    try self.matrix.items[column_index].addCard(newCard);
}

/// Removes the last card from the specified row.
pub fn removeCard(self: *CardMatrix, column_index: usize) ?Card {
    return self.matrix.items[column_index].removeCardByIndex(self.matrix.items[column_index].cards.items.len - 1);
}

/// Returns the card at the given row and column.
pub fn lookUp(self: *CardMatrix, column_index: usize, rowIndex: usize) ?Card {
    return self.matrix.items[column_index].lookUpByIndex(rowIndex);
}

/// Clears a column.
pub fn clearColumn(self: *CardMatrix, column_index: usize) void {
    self.matrix.items[column_index].clear();
}

test "matrix init" {
    const alloc = std.testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 4, 1);
    defer card_matrix.deinit();

    try std.testing.expect(card_matrix.matrix.items.len == 4);
}

test "column size" {
    const alloc = std.testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 3);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);

    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);

    try std.testing.expectEqual(3, card_matrix.columnSize(0));
    try std.testing.expectEqual(3, card_matrix.columnSize(1));
}

test "reset size" {
    const alloc = std.testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 3);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);

    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);

    card_matrix.reset();

    try std.testing.expectEqual(0, card_matrix.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(0, card_matrix.matrix.items[1].cards.items.len);
}

test "add card to row" {
    const alloc = std.testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 24);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    try card_matrix.addCard(0, card_one);
    try card_matrix.addCard(1, card_one);

    try std.testing.expectEqual(1, card_matrix.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(1, card_matrix.matrix.items[1].cards.items.len);
}

test "look up deck" {
    const alloc = std.testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 24);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Diamond };
    const card_three = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_four = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };

    try card_matrix.addCard(1, card_one);
    try card_matrix.addCard(1, card_two);
    try card_matrix.addCard(1, card_three);
    try card_matrix.addCard(1, card_four);

    try std.testing.expectEqual(card_three, card_matrix.lookUp(1, 2));
}

test "clear column" {
    const alloc = std.testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 3);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);

    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);

    card_matrix.clearColumn(1);

    try std.testing.expectEqual(3, card_matrix.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(0, card_matrix.matrix.items[1].cards.items.len);
}
