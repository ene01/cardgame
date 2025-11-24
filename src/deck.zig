//! The deck definition.
const std = @import("std");
const Card = @import("card.zig");
const testing = std.testing;
const debug = std.debug;

pub const Deck = @This();

/// An `ArrayList` of cards, you can handle this manually for more control over the deck.
cards: std.ArrayList(Card),
/// The allocator used by this `Deck`.
allocator: std.mem.Allocator,
/// Seed used for random operations, leave as null to use a "current time" seed instead.
seed: ?u64 = null,

/// Returns an empty deck with the given allocator.
pub fn init(gpa: std.mem.Allocator, card_amount: usize) !Deck {
    var card_list: Deck = undefined;
    card_list = Deck{
        .cards = try std.ArrayList(Card).initCapacity(gpa, card_amount),
        .allocator = gpa,
    };
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
    return self.len() == 0;
}

/// Adds a card to the deck.
pub fn addCard(self: *Deck, card: Card) !void {
    try self.cards.append(self.allocator, card);
}

/// Removes a single card instance from the given index
pub fn removeCard(self: *Deck, index: usize) Card {
    debug.assert(self.len() != 0);
    debug.assert(index < self.len());
    return self.cards.orderedRemove(index);
}

/// Removes all instances of a card from the deck and returns the amount of cards removed.
pub fn removeMultipleCardsByID(self: *Deck, card: Card) usize {
    var i: usize = 0;
    var removed: usize = 0;

    while (i < self.len()) {
        if (Card.isCardEqual(self.cards.items[i], card)) {
            _ = self.cards.orderedRemove(i);
            removed += 1;
            // if a card is removed, the next card shifts into the next index, so no need to increment.
        } else {
            i += 1;
        }
    }
    return removed;
}

/// Returns the card at the specified index.
pub fn lookupByIndex(self: *Deck, index: usize) Card {
    debug.assert(self.len() != 0);
    debug.assert(index < self.len());
    return self.cards.items[index];
}

/// Returns the index of a given card, returns null if the card was not found.
pub fn tryLookupByCard(self: *Deck, card: Card) ?usize {
    debug.assert(self.len() != 0);

    for (self.cards.items, 0..) |current_card, index| {
        if (Card.isCardEqual(card, current_card)) {
            return index;
        }
    }
    return null;
}

/// Counts teh amount of the card specified.
pub fn countCardType(self: *Deck, card: Card) usize {
    var counter: usize = 0;
    for (self.cards.items) |current_card| {
        if (Card.isCardEqual(card, current_card)) {
            counter += 1;
        }
    }
    return counter;
}

/// Returns a random card from the deck.
pub fn randomLookUp(self: *Deck) Card {
    debug.assert(self.len() != 0);
    var rng = random(self.seed);
    const number = rng.random().uintLessThan(usize, self.len());
    return self.cards.items[number];
}

/// Shuffles the deck.
pub fn shuffle(self: *Deck) void {
    var rng = random(self.seed);
    rng.random().shuffle(Card, self.cards.items);
}

fn random(seed: ?u64) std.Random.Xoshiro256 {
    var rng: std.Random.Xoshiro256 = undefined;
    var time_seed: u64 = undefined;

    if (seed) |valid_seed| {
        rng = std.Random.DefaultPrng.init(valid_seed);
    } else {
        time_seed = @intCast(std.time.nanoTimestamp());
        rng = std.Random.DefaultPrng.init(time_seed);
    }
    return rng;
}

test "deck initiation" {
    const alloc = testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try testing.expect(deck.len() == 0);
}

test "clear deck" {
    const alloc = testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    // Forcefully add a card.
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    deck.clear();

    try testing.expect(deck.len() == 0);
}

test "deck length" {
    const alloc = testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    // Forcefully add cards.
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try deck.cards.append(deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });

    try testing.expect(deck.len() == 3);
}

test "is deck empty" {
    const alloc = testing.allocator;

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try testing.expect(deck.isEmpty());
}

test "add card" {
    const alloc = testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.addCard(card_one);

    try testing.expect(deck.len() == 1 and deck.cards.items[0].rank == Card.Rank.Ace and deck.cards.items[0].suit == Card.Suit.Spade);
}

test "remove by index" {
    const alloc = testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);

    const removed_card = deck.removeCard(0);

    try testing.expect(deck.len() == 0 and removed_card.rank == card_one.rank and removed_card.suit == card_one.suit);
}

test "remove multiple by id" {
    const alloc = testing.allocator;
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

    const amount_removed = deck.removeMultipleCardsByID(card_one);

    try testing.expect(deck.len() == 1 and deck.cards.items[0].rank == card_two.rank and deck.cards.items[0].suit == card_two.suit);
    try testing.expectEqual(5, amount_removed);
}

test "try look up by index" {
    const alloc = testing.allocator;

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

    const picked_card_one = deck.lookupByIndex(3);
    try testing.expect(deck.cards.items[3].rank == picked_card_one.rank and deck.cards.items[3].suit == picked_card_one.suit);
}

test "try look up by id" {
    const alloc = testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };
    const card_unused = Card{ .rank = Card.Rank.Six, .suit = Card.Suit.Diamond };

    var deck = try Deck.init(alloc, 10);
    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    const card_index_one = deck.tryLookupByCard(card_four);
    try testing.expect(card_index_one != null);
    try testing.expect(deck.cards.items[card_index_one.?].rank == card_four.rank and deck.cards.items[card_index_one.?].suit == card_four.suit);

    const card_index_two = deck.tryLookupByCard(card_unused); // invalid.
    try testing.expect(card_index_two == null);
}

test "count card type" {
    const alloc = testing.allocator;
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

    try testing.expect(deck.countCardType(card_five) == 3);
}

test "random look up" {
    const alloc = testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
    deck.seed = 12345;

    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    const picked_card = deck.randomLookUp();

    try testing.expect(picked_card.rank == card_four.rank and picked_card.suit == card_four.suit);
}

test "shuffle" {
    const alloc = testing.allocator;
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const card_two = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const card_four = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Diamond };
    const card_five = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Heart };
    const card_six = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Spade };
    const card_seven = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Club };

    var deck = try Deck.init(alloc, 10);
    deck.seed = 12345;

    defer deck.deinit();

    try deck.cards.append(deck.allocator, card_one);
    try deck.cards.append(deck.allocator, card_two);
    try deck.cards.append(deck.allocator, card_three);
    try deck.cards.append(deck.allocator, card_four);
    try deck.cards.append(deck.allocator, card_five);
    try deck.cards.append(deck.allocator, card_six);
    try deck.cards.append(deck.allocator, card_seven);

    deck.shuffle();

    try testing.expect(deck.cards.items[0].rank == card_four.rank and deck.cards.items[0].suit == card_four.suit);
}
