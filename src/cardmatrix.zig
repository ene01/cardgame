//! Provides a struct for a card matrix.
const Card = @import("card.zig");
const Deck = @import("deck.zig");
const std = @import("std");
const testing = std.testing;
const debug = std.debug;

pub const CardMatrix = @This();

/// List of decks forming the matrix.
matrix: std.ArrayList(Deck),

/// Allocator used by this matrix.
allocator: std.mem.Allocator,

/// Creates a matrix with `columns` decks, each sized for `rows` cards.
pub fn init(gpa: std.mem.Allocator, columns: usize, rows: usize) !CardMatrix {
    var new_matrix = CardMatrix{
        .matrix = try std.ArrayList(Deck).initCapacity(gpa, 20),
        .allocator = gpa,
    };
    var new_deck: Deck = undefined;

    // Create one deck per column.
    for (0..columns) |_| {
        new_deck = try Deck.init(gpa, rows);
        try new_matrix.matrix.append(gpa, new_deck);
    }

    return new_matrix;
}

/// Frees all decks and the matrix itself.
pub fn deinit(self: *CardMatrix) void {
    for (self.matrix.items) |*currentDeck| {
        currentDeck.deinit();
    }
    self.matrix.deinit(self.allocator);
}

/// Returns the current amount of columns.
pub fn countColumns(self: *CardMatrix) usize {
    return self.matrix.items.len;
}

/// Returns the pointer to a deck inside the matrix.
pub fn getDeck(self: *CardMatrix, column: usize) *Deck {
    debug.assert(column < self.countColumns());
    return &self.matrix.items[column];
}

/// Returns the number of cards in a column.
pub fn columnLenght(self: *CardMatrix, column: usize) usize {
    debug.assert(column < self.countColumns());
    return self.matrix.items[column].cards.items.len;
}

/// Clears all columns.
pub fn reset(self: *CardMatrix) void {
    for (self.matrix.items) |*deck| {
        deck.clear();
    }
}

/// Adds a card to a column.
pub fn addCard(self: *CardMatrix, column: usize, new_card: Card) !void {
    debug.assert(column < self.countColumns());
    try self.matrix.items[column].addCard(new_card);
}

pub fn removeCardsByID(self: *CardMatrix, column: usize, card: Card) usize {
    debug.assert(column < self.countColumns());
    return self.matrix.items[column].removeMultipleCardsByID(card);
}

pub fn removeCard(self: *CardMatrix, column: usize, index: usize) Card {
    debug.assert(column < self.countColumns());
    return self.matrix.items[column].removeCard(index);
}

/// Returns a card at the given column and row.
pub fn lookupColumnByIndex(self: *CardMatrix, column: usize, row_index: usize) Card {
    debug.assert(column < self.countColumns());
    return self.matrix.items[column].lookupByIndex(row_index);
}

/// Returns a card at the given column and row.
pub fn tryLookupColumnByCard(self: *CardMatrix, column: usize, card: Card) ?usize {
    debug.assert(column < self.countColumns());
    return self.matrix.items[column].tryLookupByCard(card);
}

/// Clears a single column.
pub fn clearColumn(self: *CardMatrix, column: usize) void {
    debug.assert(column < self.countColumns());
    self.matrix.items[column].clear();
}

test "matrix init" {
    const alloc = testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 4, 1);
    defer card_matrix.deinit();

    try testing.expect(card_matrix.matrix.items.len == 4);
}

test "get deck" {
    const alloc = testing.allocator;

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

    var deck = card_matrix.getDeck(1);

    const card_picked = deck.lookupByIndex(2);
    try testing.expectEqual(card_three, card_picked);
}

test "column size" {
    const alloc = testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 3);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);
    try card_matrix.matrix.items[0].cards.append(alloc, card_one);

    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);
    try card_matrix.matrix.items[1].cards.append(alloc, card_one);

    try testing.expectEqual(3, card_matrix.columnLenght(0));
    try testing.expectEqual(3, card_matrix.columnLenght(1));
}

test "reset size" {
    const alloc = testing.allocator;

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

    try testing.expectEqual(0, card_matrix.matrix.items[0].cards.items.len);
    try testing.expectEqual(0, card_matrix.matrix.items[1].cards.items.len);
}

test "add card to row" {
    const alloc = testing.allocator;

    var card_matrix = try CardMatrix.init(alloc, 2, 24);
    defer card_matrix.deinit();

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    try card_matrix.addCard(0, card_one);
    try card_matrix.addCard(1, card_one);

    try testing.expectEqual(1, card_matrix.matrix.items[0].cards.items.len);
    try testing.expectEqual(1, card_matrix.matrix.items[1].cards.items.len);
}

test "try look up column by index" {
    const alloc = testing.allocator;

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

    const card_picked = card_matrix.lookupColumnByIndex(1, 2);
    try testing.expectEqual(card_three, card_picked);
}

test "clear column" {
    const alloc = testing.allocator;

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

    try testing.expectEqual(3, card_matrix.matrix.items[0].cards.items.len);
    try testing.expectEqual(0, card_matrix.matrix.items[1].cards.items.len);
}
