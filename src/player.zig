const std = @import("std");
const card = @import("card.zig");
const cardmatrix = @import("cardmatrix.zig");
const deck = @import("deck.zig");

/// Player attributes: hand, rows, and status.
pub const Attributes = struct {
    hand: deck.PlayingCards,
    discard_deck: deck.PlayingCards,
    matrix: cardmatrix.CardMatrix,
    is_playing: bool,

    /// Initializes and returns a player's attributes with an empty hand.
    pub fn init(alloc: std.mem.Allocator, columnAmount: usize) !Attributes {
        return Attributes{ .hand = deck.PlayingCards.init(alloc), .discard_deck = deck.PlayingCards.init(alloc), .matrix = try cardmatrix.CardMatrix.init(alloc, columnAmount), .is_playing = true };
    }

    /// Releases memory for dynamic arrays (hand).
    pub fn deinit(self: *Attributes) void {
        self.hand.deinit();
        self.matrix.deinit();
    }

    /// Adds a card to the player's hand.
    pub fn addToHand(self: *Attributes, newCard: card.Identity) !void {
        try self.hand.addCard(newCard);
    }

    /// Adds a card to the specified row.
    pub fn addToRow(self: *Attributes, newCard: card.Identity, row: usize) !void {
        try self.matrix.addCard(@intCast(row), newCard);
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
        return self.matrix.removeCard(column);
    }
};
