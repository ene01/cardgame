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
    pub fn init(alloc: std.mem.Allocator, columnAmount: usize) !Attributes {
        return Attributes{ .hand = deck.CardList.init(alloc), .discard_deck = deck.CardList.init(alloc), .tableau = try cardmatrix.CardMatrix.init(alloc, columnAmount), .is_playing = true };
    }

    /// Releases memory for dynamic arrays (hand).
    pub fn deinit(self: *Attributes) void {
        self.hand.deinit();
        self.tableau.deinit();
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

    const player_one = try Attributes.init(alloc, 4);
    defer player_one.deinit();

    try std.testing.expectEqual(player_one.tableau.matrix.items.len, 4);
    try std.testing.expectEqual(player_one.discard_deck.len(), 0);
    try std.testing.expectEqual(player_one.hand.len(), 0);
    try std.testing.expect(player_one.is_playing);
}
