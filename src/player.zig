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
    pub fn init(gpa: std.mem.Allocator, hand_size: usize, discard_size: usize, columns: usize, column_deck_size: usize) !Attributes {
        return Attributes{ .hand = try deck.CardList.init(gpa, hand_size), .discard_deck = try deck.CardList.init(gpa, discard_size), .tableau = try cardmatrix.CardMatrix.init(gpa, columns, column_deck_size), .is_playing = true };
    }

    /// Releases memory for dynamic arrays (hand).
    pub fn deinit(self: *Attributes) void {
        self.hand.deinit();
        self.tableau.deinit();
        self.discard_deck.deinit();
    }

    /// Adds a card to the player's hand.
    pub fn addToHand(self: *Attributes, new_card: card.Identity) !void {
        try self.hand.addCard(new_card);
    }

    /// Adds a card to the specified row.
    pub fn addToRow(self: *Attributes, new_card: card.Identity, row_index: usize) !void {
        try self.tableau.addCard(@intCast(row_index), new_card);
    }

    /// Removes a single instance of a card from the player's hand.
    pub fn removeCardFromHand(self: *Attributes, card_to_remove: card.Identity) ?usize {
        return self.hand.removeCardByID(card_to_remove);
    }

    /// Removes all instances of a card from the player's hand.
    pub fn removeCardsFromHand(self: *Attributes, card_to_remove: card.Identity) ?usize {
        return self.hand.removeCardByID(card_to_remove);
    }

    /// Removes the last card from the specified row.
    pub fn removeCardFromColumn(self: *Attributes, column_index: usize) ?card.Identity {
        return self.tableau.removeCard(column_index);
    }
};

test "player initiation" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    try std.testing.expectEqual(player_one.tableau.matrix.items.len, 4);
    try std.testing.expectEqual(player_one.discard_deck.len(), 0);
    try std.testing.expectEqual(player_one.hand.len(), 0);
    try std.testing.expect(player_one.is_playing);
}
