const std = @import("std");
const card = @import("card.zig");
const cardmatrix = @import("cardmatrix.zig");

/// Initializes and returns a player's attributes with an empty hand and default rows.
pub fn init(alloc: std.mem.Allocator) PAttributes {
    return PAttributes{ .hand = std.ArrayList(card.CAttributes).init(alloc), .rows = cardmatrix.init(), .is_playing = true };
}

/// Player attributes: hand, rows, and status.
pub const PAttributes = struct {
    hand: std.ArrayList(card.CAttributes),
    rows: cardmatrix.Matrix,
    is_playing: bool,

    /// Releases memory for dynamic arrays (hand).
    pub fn deinit(self: *PAttributes) void {
        self.hand.deinit();
    }

    /// Adds a card to the player's hand.
    pub fn addToHand(self: *PAttributes, newCard: card.CAttributes) !void {
        try self.hand.append(newCard);
    }

    /// Adds a card to the specified row.
    pub fn addToRow(self: *PAttributes, newCard: card.CAttributes, row: usize) !void {
        try self.rows.addCard(@intCast(row), newCard);
    }

    /// Removes a single instance of a card from the player's hand.
    pub fn removeFromHand(self: *PAttributes, cardToRemove: card.CAttributes) !void {
        for (self.hand.items, 0..) |currentCard, index| {
            if (currentCard.rank == cardToRemove.rank and currentCard.suit == cardToRemove.suit) {
                _ = self.hand.orderedRemove(index);
                break;
            }
        }
    }

    /// Removes all instances of a card from the player's hand.
    pub fn removeCards(self: *PAttributes, cardToRemove: card.CAttributes) !void {
        var found = true;
        while (found) {
            found = false;
            for (self.hand.items, 0..) |currentCard, index| {
                if (currentCard.rank == cardToRemove.rank and currentCard.suit == cardToRemove.suit) {
                    _ = self.hand.orderedRemove(index);
                    found = true;
                    break;
                }
            }
        }
    }

    /// Removes and returns the last card from the specified row.
    pub fn removeFromRow(self: *PAttributes, row: usize) !card.CAttributes {
        const removed_card = try self.rows.checkMatrix(@intCast(row), self.rows.row_last_index[@intCast(row)]);
        try self.rows.removeCard(@intCast(row));
        return removed_card;
    }
};
