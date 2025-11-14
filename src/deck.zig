//! The deck definition.
const std = @import("std");
const card = @import("card.zig");
const logging = @import("log.zig");

/// A dynamic deck of cards.
pub const CardList = struct {
    /// An ArrayList of cards, you can handle this manually for more control over the deck.
    cards: std.ArrayList(card.Identity),
    /// The allocator used by this struct.
    allocator: std.mem.Allocator,

    /// Returns an empty deck with the given allocator.
    pub fn init(gpa: std.mem.Allocator, card_amount: usize) !CardList {
        var card_list: CardList = undefined;

        card_list = CardList{ .cards = try std.ArrayList(card.Identity).initCapacity(gpa, card_amount), .allocator = gpa };

        return card_list;
    }

    /// Releases memory used by the deck.
    pub fn deinit(self: *CardList) void {
        self.cards.deinit(self.allocator);
    }

    /// Clears all cards on the deck.
    pub fn clear(self: *CardList) void {
        self.cards.clearRetainingCapacity();
    }

    pub fn len(self: *CardList) usize {
        return self.cards.items.len;
    }

    pub fn isEmpty(self: *CardList) bool {
        return self.cards.items.len == 0;
    }

    /// Adds a card to the deck.
    pub fn addCard(self: *CardList, new_card: card.Identity) !void {
        try self.cards.append(self.allocator, new_card);
    }

    /// Removes a single instance of the given card ID.
    pub fn removeCardByID(self: *CardList, card_to_Remove: card.Identity) ?usize {
        const index = self.lookUpByID(card_to_Remove);

        if (index) |valid_index| {
            _ = self.cards.orderedRemove(valid_index);
            return valid_index;
        }
        return null;
    }

    /// Removes a single card instance from the given index
    pub fn removeCardByIndex(self: *CardList, index: usize) ?card.Identity {
        if (index < self.cards.items.len) {
            return self.cards.orderedRemove(index);
        }
        return null;
    }

    /// Removes all instances of the given card from the deck.
    pub fn removeMultipleCardsByID(self: *CardList, card_to_remove: card.Identity) void {
        var i: usize = 0;
        while (i < self.cards.items.len) {
            if (card.Identity.isCardEqual(self.cards.items[i], card_to_remove)) {
                _ = self.cards.orderedRemove(i);
                // if a card is removed, the next card shifts into the next index, so no need to increment.
            } else {
                i += 1;
            }
        }
    }

    /// Returns the card at the specified index, if valid.
    pub fn lookUpByIndex(self: *CardList, index: usize) ?card.Identity {
        if (index < self.cards.items.len) {
            return self.cards.items[index];
        } else {
            return null;
        }
    }

    /// Returns the index of a given card identifier, returns null if nothing was found
    pub fn lookUpByID(self: *CardList, card_to_search: card.Identity) ?usize {
        for (self.cards.items, 0..) |currentCard, index| {
            if (card.Identity.isCardEqual(card_to_search, currentCard)) {
                return index;
            }
        }
        return null;
    }

    pub fn cardExists(self: *CardList, card_to_check: card.Identity) bool {
        for (self.cards.items) |currentCard| {
            if (card.Identity.isCardEqual(card_to_check, currentCard)) {
                return true;
            }
        }
        return false;
    }

    pub fn countCardType(self: *CardList, card_to_count: card.Identity) usize {
        var counter: usize = 0;
        for (self.cards.items) |currentCard| {
            if (card.Identity.isCardEqual(card_to_count, currentCard)) {
                counter += 1;
            }
        }
        return counter;
    }

    /// Returns a random card from the deck without reshuffling.
    pub fn randomLookUp(self: *CardList, seed: ?u64) ?card.Identity {
        if (self.cards.items.len == 0) return null;

        if (seed) |valid_Seed| {
            var rng = std.Random.DefaultPrng.init(valid_Seed);
            const number = rng.random().uintLessThan(usize, self.cards.items.len);

            return self.cards.items[number];
        } else {
            var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
            return self.cards.items[rng.random().uintLessThan(usize, self.cards.items.len)];
        }
    }

    /// Shuffles the deck. Pass `null` for a random seed.
    pub fn shuffle(self: *CardList, seed: ?u64) void {
        if (seed) |valid_seed| {
            var rng = std.Random.DefaultPrng.init(valid_seed);
            rng.random().shuffle(card.Identity, self.cards.items);
        } else {
            var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
            rng.random().shuffle(card.Identity, self.cards.items);
        }
    }
};

test "deck initiation" {
    const alloc = std.testing.allocator;

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try std.testing.expect(deck.cards.items.len == 0);
}

test "clear deck" {
    const alloc = std.testing.allocator;

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    // Forcefully add a card.
    try deck.cards.append(deck.allocator, card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club });
    deck.clear();

    try std.testing.expect(deck.len() == 0);
}

test "deck length" {
    const alloc = std.testing.allocator;

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    // Forcefully add cards.
    try deck.cards.append(deck.allocator, card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club });
    try deck.cards.append(deck.allocator, card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club });
    try deck.cards.append(deck.allocator, card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club });

    try std.testing.expect(deck.len() == 3);
}

test "is deck empty" {
    const alloc = std.testing.allocator;

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try std.testing.expect(deck.isEmpty());
}

test "add card" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.addCard(card_one);

    try std.testing.expect(deck.cards.items.len == 1 and deck.cards.items[0].rank == card.Rank.Ace and deck.cards.items[0].suit == card.Suit.Spade);
}

test "remove by id" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);

    _ = deck.removeCardByID(card_one);

    try std.testing.expect(deck.cards.items.len == 0);
}

test "remove by index" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);

    const removed_card = deck.removeCardByIndex(0).?;

    try std.testing.expect(deck.cards.items.len == 0 and removed_card.rank == card_one.rank and removed_card.suit == card_one.suit);
}

test "remove multiple by id" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_one);

    deck.removeMultipleCardsByID(card_one);

    try std.testing.expect(deck.cards.items.len == 1 and deck.cards.items[0].rank == card_two.rank and deck.cards.items[0].suit == card_two.suit);
}

test "look up by index" {
    const alloc = std.testing.allocator;
    const card_invalid = card.Identity{ .rank = card.Rank.Invalid, .suit = card.Suit.Invalid };

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_three = card.Identity{ .rank = card.Rank.Two, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Queen, .suit = card.Suit.Diamond };
    const card_five = card.Identity{ .rank = card.Rank.King, .suit = card.Suit.Heart };
    const card_six = card.Identity{ .rank = card.Rank.Ten, .suit = card.Suit.Spade };
    const card_seven = card.Identity{ .rank = card.Rank.Five, .suit = card.Suit.Club };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    var picked_card: card.Identity = undefined;

    if (deck.lookUpByIndex(3)) |valid_card| {
        picked_card = valid_card;
    } else {
        picked_card = card_invalid;
    }

    try std.testing.expect(deck.cards.items[3].rank == picked_card.rank and deck.cards.items[3].suit == picked_card.suit);
}

test "look up by id" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_three = card.Identity{ .rank = card.Rank.Two, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Queen, .suit = card.Suit.Diamond };
    const card_five = card.Identity{ .rank = card.Rank.King, .suit = card.Suit.Heart };
    const card_six = card.Identity{ .rank = card.Rank.Ten, .suit = card.Suit.Spade };
    const card_seven = card.Identity{ .rank = card.Rank.Five, .suit = card.Suit.Club };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    var picked_card_index: usize = undefined;

    if (deck.lookUpByID(card_four)) |valid_index| {
        picked_card_index = valid_index;
    } else {
        picked_card_index = 0;
    }

    try std.testing.expect(deck.cards.items[picked_card_index].rank == card_four.rank and deck.cards.items[picked_card_index].suit == card_four.suit);
}

test "card exist" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_three = card.Identity{ .rank = card.Rank.Two, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Queen, .suit = card.Suit.Diamond };
    const card_five = card.Identity{ .rank = card.Rank.King, .suit = card.Suit.Heart };
    const card_six = card.Identity{ .rank = card.Rank.Ten, .suit = card.Suit.Spade };
    const card_seven = card.Identity{ .rank = card.Rank.Five, .suit = card.Suit.Club };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    try std.testing.expect(deck.cardExists(card_five));
}

test "count card type" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_three = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Diamond };
    const card_five = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_six = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_seven = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    try std.testing.expect(deck.countCardType(card_five) == 3);
}

test "random look up" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_three = card.Identity{ .rank = card.Rank.Two, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Queen, .suit = card.Suit.Diamond };
    const card_five = card.Identity{ .rank = card.Rank.King, .suit = card.Suit.Heart };
    const card_six = card.Identity{ .rank = card.Rank.Ten, .suit = card.Suit.Spade };
    const card_seven = card.Identity{ .rank = card.Rank.Five, .suit = card.Suit.Club };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    const picked_card = deck.randomLookUp(12345).?;

    try std.testing.expect(picked_card.rank == card_four.rank and picked_card.suit == card_four.suit);
}

test "shuffle" {
    const alloc = std.testing.allocator;
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_three = card.Identity{ .rank = card.Rank.Two, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Queen, .suit = card.Suit.Diamond };
    const card_five = card.Identity{ .rank = card.Rank.King, .suit = card.Suit.Heart };
    const card_six = card.Identity{ .rank = card.Rank.Ten, .suit = card.Suit.Spade };
    const card_seven = card.Identity{ .rank = card.Rank.Five, .suit = card.Suit.Club };

    var deck = try CardList.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    deck.shuffle(12345);

    try std.testing.expect(deck.cards.items[0].rank == card_four.rank and deck.cards.items[0].suit == card_four.suit);
}
