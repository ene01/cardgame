const std = @import("std");
const card = @import("card.zig");
const rank = @import("rank.zig");
const suit = @import("suit.zig");

/// Create an empty deck with the given allocator.
pub fn init(allocator: std.mem.Allocator) Cards {
    return Cards{ .cards = std.ArrayList(card.CAttributes).init(allocator) };
}

/// A dynamic deck of cards.
pub const Cards = struct {
    cards: std.ArrayList(card.CAttributes),

    /// Releases memory used by the deck.
    pub fn deinit(self: *Cards) void {
        self.cards.deinit();
    }

    /// Adds a card to the deck.
    pub fn addCard(self: *Cards, newCard: card.CAttributes) !void {
        try self.cards.append(newCard);
    }

    /// Removes a single instance of the given card from the deck.
    pub fn removeSingleCard(self: *Cards, cardToRemove: card.CAttributes) !void {
        for (self.cards.items, 0..) |currentCard, index| {
            if (currentCard.rank == cardToRemove.rank and currentCard.suit == cardToRemove.suit) {
                _ = self.cards.orderedRemove(index);
                return;
            }
        }
        std.debug.print("[Deck - removeSingleCard] Card not found: {}\n", .{cardToRemove});
    }

    /// Removes all instances of the given card from the deck.
    pub fn removeCards(self: *Cards, cardToRemove: card.CAttributes) !void {
        var found = true;
        while (found) {
            found = false;
            for (self.cards.items, 0..) |currentCard, index| {
                if (currentCard.rank == cardToRemove.rank and currentCard.suit == cardToRemove.suit) {
                    _ = self.cards.orderedRemove(index);
                    found = true;
                    break;
                }
            }
        }
    }

    /// Returns the card at the specified index, if valid.
    pub fn lookUp(self: *Cards, index: usize) !card.CAttributes {
        if (index < self.cards.items.len) {
            return self.cards.items[index];
        } else {
            std.debug.print("[Deck - lookUp] Index out of range: {} >= {}\n", .{ index, self.cards.items.len });
        }
    }

    /// Returns a random card from the deck.
    pub fn randomLookUp(self: *Cards) !card.CAttributes {
        var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        return self.cards.items[rng.random().uintLessThan(usize, self.cards.items.len)];
    }

    /// Shuffles the deck. Pass `null` for a random seed.
    pub fn shuffle(self: *Cards, seed: ?u64) void {
        var rng = if (seed) {
            std.Random.DefaultPrng.init(seed);
        } else {
            std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        };

        rng.random().shuffle(card.CAttributes, self.cards.items);
    }
};
