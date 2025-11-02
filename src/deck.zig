const std = @import("std");
const card = @import("card.zig");
const rank = @import("rank.zig");
const suit = @import("suit.zig");

/// A dynamic deck of cards.
pub const PlayingCards = struct {
    cards: std.ArrayList(card.Identity),

    /// Create an empty deck with the given allocator.
    pub fn init(allocator: std.mem.Allocator) PlayingCards {
        return PlayingCards{ .cards = std.ArrayList(card.Identity).init(allocator) };
    }

    /// Releases memory used by the deck.
    pub fn deinit(self: *PlayingCards) void {
        self.cards.deinit();
    }

    /// Clears all cards on the deck.
    pub fn clear(self: *PlayingCards) void {
        self.cards.clearRetainingCapacity();
    }

    pub fn len(self: *PlayingCards) usize {
        return self.cards.items.len;
    }

    pub fn isEmpty(self: *PlayingCards) bool {
        return self.cards.items.items.len == 0;
    }

    /// Adds a card to the deck.
    pub fn addCard(self: *PlayingCards, newCard: card.Identity) !void {
        try self.cards.append(newCard);
    }

    /// Removes a single instance of the given card ID.
    pub fn removeCardByID(self: *PlayingCards, cardToRemove: card.Identity) ?usize {
        const index = self.lookUpByID(cardToRemove);

        if (index) |valid_index| {
            _ = self.cards.orderedRemove(valid_index);
            return valid_index;
        }
        return null;
    }

    /// Removes a single card instance from the given index
    pub fn removeCardByIndex(self: *PlayingCards, index: usize) ?card.Identity {
        if (index < self.cards.items.len) {
            return self.cards.orderedRemove(index);
        }
        return null;
    }

    /// Removes all instances of the given card from the deck.
    pub fn removeMultipleCardsByID(self: *PlayingCards, cardToRemove: card.Identity) void {
        var i: usize = 0;
        while (i < self.cards.items.len) {
            if (card.Identity.isCardEqual(self.cards.items[i], cardToRemove)) {
                _ = self.cards.orderedRemove(i);
                // if a card is removed, the next card shifts into the next index, so no need to increment.
            } else {
                i += 1;
            }
        }
    }

    /// Returns the card at the specified index, if valid.
    pub fn lookUpByIndex(self: *PlayingCards, index: usize) ?card.Identity {
        if (index < self.cards.items.len) {
            return self.cards.items[index];
        } else {
            return null;
        }
    }

    /// Returns the index of a given card identifier, returns null if nothing was found
    pub fn lookUpByID(self: *PlayingCards, cardToSearch: card.Identity) ?usize {
        for (self.cards.items, 0..) |currentCard, index| {
            if (card.Identity.isCardEqual(cardToSearch, currentCard)) {
                return index;
            }
        }
        return null;
    }

    pub fn cardExists(self: *PlayingCards, cardToCheck: card.Identity) bool {
        for (self.cards.items) |currentCard| {
            if (card.Identity.isCardEqual(cardToCheck, currentCard)) {
                return true;
            }
        }
        return false;
    }

    pub fn countCardType(self: *PlayingCards, cardToCount: card.Identity) usize {
        var counter: usize = 0;
        for (self.cards.items) |currentCard| {
            if (card.Identity.isCardEqual(cardToCount, currentCard)) {
                counter += 1;
            }
        }
        return counter;
    }

    /// Returns a random card from the deck without reshuffling.
    pub fn randomLookUp(self: *PlayingCards, seed: ?u64) ?card.Identity {
        if (self.cards.items.len == 0) return null;

        var rng = if (seed) |valid_Seed| {
            std.Random.DefaultPrng.init(valid_Seed);
        } else {
            std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        };

        return self.cards.items[rng.random().uintLessThan(usize, self.cards.items.len)];
    }

    // Shuffle deck and pick the first card.
    pub fn shuffleLookUp(self: *PlayingCards, seed: ?u64) ?card.Identity {
        if (self.cards.items.len == 0) return null;

        self.shuffle(seed);
        return self.cards.items[0];
    }

    /// Shuffles the deck. Pass `null` for a random seed.
    pub fn shuffle(self: *PlayingCards, seed: ?u64) void {
        var rng = if (seed) |valid_seed| {
            std.Random.DefaultPrng.init(valid_seed);
        } else {
            std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        };

        rng.random().shuffle(card.Identity, self.cards.items);
    }
};
