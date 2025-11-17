//! The deck definition.
const std = @import("std");
const Card = @import("card.zig");

pub const Deck = @This();

/// An ArrayList of cards, you can handle this manually for more control over the deck.
cards: std.ArrayList(Card),
/// The allocator used by this struct.
allocator: std.mem.Allocator,

/// Returns an empty deck with the given allocator.
pub fn init(gpa: std.mem.Allocator, card_amount: usize) !Deck {
    var card_list: Deck = undefined;

    card_list = Deck{ .cards = try std.ArrayList(Card).initCapacity(gpa, card_amount), .allocator = gpa };

    return card_list;
}

/// Releases memory used by the deck.
pub fn deinit(self: *Deck) void {
    self.cards.deinit(self.allocator);
}

/// Clears all cards on the deck.
pub fn clear(self: *Deck) void {
    self.cards.clearRetainingCapacity();
}

pub fn len(self: *Deck) usize {
    return self.cards.items.len;
}

pub fn isEmpty(self: *Deck) bool {
    return self.cards.items.len == 0;
}

/// Adds a card to the deck.
pub fn addCard(self: *Deck, new_card: Card) !void {
    try self.cards.append(self.allocator, new_card);
}

/// Removes a single instance of the given card ID.
pub fn removeCardByID(self: *Deck, card_to_Remove: Card) ?usize {
    const index = self.lookUpByID(card_to_Remove);

    if (index) |valid_index| {
        _ = self.cards.orderedRemove(valid_index);
        return valid_index;
    }
    return null;
}

/// Removes a single card instance from the given index
pub fn removeCardByIndex(self: *Deck, index: usize) ?Card {
    if (index < self.cards.items.len) {
        return self.cards.orderedRemove(index);
    }
    return null;
}

/// Removes all instances of the given card from the deck.
pub fn removeMultipleCardsByID(self: *Deck, card_to_remove: Card) void {
    var i: usize = 0;
    while (i < self.cards.items.len) {
        if (Card.isCardEqual(self.cards.items[i], card_to_remove)) {
            _ = self.cards.orderedRemove(i);
            // if a card is removed, the next card shifts into the next index, so no need to increment.
        } else {
            i += 1;
        }
    }
}

/// Returns the card at the specified index, if valid.
pub fn lookUpByIndex(self: *Deck, index: usize) ?Card {
    if (index < self.cards.items.len) {
        return self.cards.items[index];
    } else {
        return null;
    }
}

/// Returns the index of a given card identifier, returns null if nothing was found
pub fn lookUpByID(self: *Deck, card_to_search: Card) ?usize {
    for (self.cards.items, 0..) |currentCard, index| {
        if (Card.isCardEqual(card_to_search, currentCard)) {
            return index;
        }
    }
    return null;
}

pub fn cardExists(self: *Deck, card_to_check: Card) bool {
    for (self.cards.items) |currentCard| {
        if (Card.isCardEqual(card_to_check, currentCard)) {
            return true;
        }
    }
    return false;
}

pub fn countCardType(self: *Deck, card_to_count: Card) usize {
    var counter: usize = 0;
    for (self.cards.items) |currentCard| {
        if (Card.isCardEqual(card_to_count, currentCard)) {
            counter += 1;
        }
    }
    return counter;
}

/// Returns a random card from the deck without reshuffling.
pub fn randomLookUp(self: *Deck, seed: ?u64) ?Card {
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
pub fn shuffle(self: *Deck, seed: ?u64) void {
    if (seed) |valid_seed| {
        var rng = std.Random.DefaultPrng.init(valid_seed);
        rng.random().shuffle(Card, self.cards.items);
    } else {
        var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
        rng.random().shuffle(Card, self.cards.items);
    }
}

test "deck initiation" {
    const alloc = std.testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try std.testing.expect(deck.cards.items.len == 0);
}

test "clear deck" {
    const alloc = std.testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    // Forcefully add a card.
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    deck.clear();

    try std.testing.expect(deck.len() == 0);
}

test "deck length" {
    const alloc = std.testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    // Forcefully add cards.
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });

    try std.testing.expect(deck.len() == 3);
}

test "is deck empty" {
    const alloc = std.testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try std.testing.expect(deck.isEmpty());
}

test "add card" {
    const alloc = std.testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.addCard(card_one);

    try std.testing.expect(deck.cards.items.len == 1 and deck.cards.items[0].rank == Card.Rank.Ace and deck.cards.items[0].suit == Card.Suit.Spade);
}

test "remove by id" {
    const alloc = std.testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);

    _ = deck.removeCardByID(card_one);

    try std.testing.expect(deck.cards.items.len == 0);
}

test "remove by index" {
    const alloc = std.testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);

    const removed_card = deck.removeCardByIndex(0).?;

    try std.testing.expect(deck.cards.items.len == 0 and removed_card.rank == card_one.rank and removed_card.suit == card_one.suit);
}

test "remove multiple by id" {
    const alloc = std.testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    var deck = try Deck.init(alloc, 10);
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
    const card_invalid = Card{ .rank = Card.Rank.Invalid, .suit = Card.Suit.Invalid };

    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    var picked_card: Card = undefined;

    if (deck.lookUpByIndex(3)) |valid_card| {
        picked_card = valid_card;
    } else {
        picked_card = card_invalid;
    }

    try std.testing.expect(deck.cards.items[3].rank == picked_card.rank and deck.cards.items[3].suit == picked_card.suit);
}

test "look up by id" {
    const alloc = std.testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
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
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
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
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_seven = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
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
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
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
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
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
