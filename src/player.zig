const std = @import("std");
const card = @import("card.zig");
const cardmatrix = @import("card_matrix.zig");
const deck = @import("deck.zig");

/// Player attributes: hand, rows, and status.
pub const Attributes = struct {
    hand: deck.CardList,
    discard_deck: deck.CardList,
    tableau: cardmatrix.CardMatrix,
    is_playing: bool,

    /// Initializes and returns a player's attributes with an empty hand.
    pub fn init(gpa: std.mem.Allocator, columnAmount: usize, handSize: usize, discardAmount: usize, cardsPerColumn: usize) !Attributes {
        return Attributes{ .hand = try deck.CardList.init(gpa, handSize), .discard_deck = try deck.CardList.init(gpa, discardAmount), .tableau = try cardmatrix.CardMatrix.init(gpa, columnAmount, cardsPerColumn), .is_playing = true };
    }

    /// Releases memory for dynamic arrays (hand).
    pub fn deinit(self: *Attributes) void {
        self.hand.deinit();
        self.tableau.deinit();
        self.discard_deck.deinit();
    }

    /// Adds a card to the player's hand.
    pub fn addToHand(self: *Attributes, newCard: card.Identity) !void {
        try self.hand.addCard(newCard);
    }

    /// Adds a card to the specified row.
    pub fn addToRow(self: *Attributes, newCard: card.Identity, row: usize) !void {
        try self.tableau.addCard(@intCast(row), newCard);
    }

    /// Removes a single instance of a card from the player's hand.
    pub fn removeCardFromHand(self: *Attributes, cardToRemove: card.Identity) ?usize {
        return self.hand.removeCardByID(cardToRemove);
    }

    /// Removes all instances of a card from the player's hand.
    pub fn removeCardsFromHand(self: *Attributes, cardToRemove: card.Identity) ?usize {
        return self.hand.removeCardByID(cardToRemove);
    }

    /// Removes the last card from the specified row.
    pub fn removeCardFromColumn(self: *Attributes, column: usize) ?card.Identity {
        return self.tableau.removeCard(column);
    }
};

test "player initiation" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 4, 5, 10, 52);
    defer player_one.deinit();

    try std.testing.expectEqual(player_one.tableau.matrix.items.len, 4);
    try std.testing.expectEqual(player_one.discard_deck.len(), 0);
    try std.testing.expectEqual(player_one.hand.len(), 0);
    try std.testing.expect(player_one.is_playing);
}
