//! Extra deck operations that don’t belong in the core deck module.
const Deck = @import("deck.zig");
const Card = @import("card.zig");
const std = @import("std");
const cardutils = @import("cardutils.zig");
const testing = std.testing;
const debug = std.debug;
const log = @import("log.zig");

/// Appends one or more standard 52-card decks. Jokers can be optionally included.
pub fn appendStandardDeck(deck: *Deck, times: usize, jokers: bool) !void {
    for (0..times) |_| {
        // Suits: Club → Diamond.
        for ((@intFromEnum(Card.Suit.Club))..(@intFromEnum(Card.Suit.Diamond)) + 1) |suit_int| {
            // Ranks: Ace → Two.
            for ((@intFromEnum(Card.Rank.Ace))..(@intFromEnum(Card.Rank.Two)) + 1) |rank_int| {
                try deck.addCard(Card{
                    .rank = @enumFromInt(rank_int),
                    .suit = @enumFromInt(suit_int),
                });
            }
        }

        if (jokers) {
            try deck.addCard(Card{ .rank = Card.Rank.Joker, .suit = Card.Suit.All });
            try deck.addCard(Card{ .rank = Card.Rank.Joker, .suit = Card.Suit.All });
        }
    }
}

/// Moves a specific card from one deck to another by its index.
pub fn transferCardByIndex(from_deck: *Deck, index_from: usize, to_deck: *Deck) !void {
    const card = from_deck.lookupByIndex(index_from);
    try to_deck.addCard(card);
    _ = from_deck.removeCard(index_from);
}

/// Moves a specific card from one deck to another by its ID.
pub fn transferCardByID(from_deck: *Deck, card: Card, to_deck: *Deck) !void {
    const card_index = from_deck.tryLookupByCard(card);

    debug.assert(card_index != null);

    try to_deck.addCard(card);
    _ = from_deck.removeCard(card_index.?);
}

/// Moves a random card from one deck to another.
pub fn transferRandomCard(from_deck: *Deck, to_deck: *Deck) !void {
    debug.assert(from_deck.len() != 0);

    var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    const index = rng.random().uintLessThan(usize, from_deck.len());

    const card = from_deck.lookupByIndex(index);
    try to_deck.addCard(card);
    _ = from_deck.removeCard(index);
}

/// Returns a new deck containing all cards from both decks.
pub fn combineDecks(alloc: std.mem.Allocator, deck_one: *Deck, deck_two: *Deck) !Deck {
    var combined = try Deck.init(alloc, deck_one.len() + deck_two.len());

    for (deck_one.cards.items) |c| try combined.addCard(c);
    for (deck_two.cards.items) |c| try combined.addCard(c);

    return combined;
}

/// Sorts the deck by suit, and within each suit sorts by rank.
pub fn orderDeckBySuit(deck: *Deck) !void {
    if (deck.len() == 0) {
        return;
    }

    var buffer: [2048]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buffer[0..]);
    const alloc = fba.allocator();

    var ordered = try Deck.init(alloc, deck.len());
    defer ordered.deinit();

    var count: u16 = 0;

    for ((@intFromEnum(Card.Suit.All))..(@intFromEnum(Card.Suit.Diamond)) + 1) |suit_int| {
        for ((@intFromEnum(Card.Rank.Ace))..(@intFromEnum(Card.Rank.Two)) + 1) |rank_int| {
            const card = Card{
                .rank = @enumFromInt(rank_int),
                .suit = @enumFromInt(suit_int),
            };

            if (deck.tryLookupByCard(card)) |_| {
                try ordered.addCard(card);
                count += 1;
                if (count == deck.len()) break;
            }
        }
    }

    deck.clear();
    for (ordered.cards.items) |c| try deck.addCard(c);
}

/// Sorts the deck from Ace → Two.
pub fn orderDeckByRankDescending(deck: *Deck) !void {
    if (deck.len() == 0) {
        return;
    }

    var buffer: [2048]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buffer[0..]);
    const alloc = fba.allocator();

    var ordered = try Deck.init(alloc, deck.len());
    defer ordered.deinit();

    var count: u16 = 0;

    for ((@intFromEnum(Card.Rank.Joker))..(@intFromEnum(Card.Rank.Two)) + 1) |rank_int| {
        for ((@intFromEnum(Card.Suit.All))..(@intFromEnum(Card.Suit.Diamond)) + 1) |suit_int| {
            const card = Card{
                .rank = @enumFromInt(rank_int),
                .suit = @enumFromInt(suit_int),
            };

            if (deck.tryLookupByCard(card)) |_| {
                try ordered.addCard(card);
                count += 1;
                if (count == deck.len()) break;
            }
        }
    }

    deck.clear();
    for (ordered.cards.items) |c| try deck.addCard(c);
}

/// Sorts the deck from Two → Ace.
pub fn orderDeckByRankAscending(deck: *Deck) !void {
    if (deck.len() == 0) {
        return;
    }

    var buffer: [2048]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(buffer[0..]);
    const alloc = fba.allocator();

    var ordered = try Deck.init(alloc, deck.len());
    defer ordered.deinit();

    // leaving a comment because i forget how to read this, this basically goes backwards, remember that.
    var count: u16 = 0;
    var rank_int: u8 = @intFromEnum(Card.Rank.Two);
    while (rank_int + 1 > 1) : (rank_int -= 1) {
        for ((@intFromEnum(Card.Suit.All))..(@intFromEnum(Card.Suit.Diamond)) + 1) |suit_int| {
            const card = Card{
                .rank = @enumFromInt(rank_int),
                .suit = @enumFromInt(suit_int),
            };

            if (deck.tryLookupByCard(card)) |_| {
                try ordered.addCard(card);
                count += 1;
                if (count == deck.len()) break;
            }
        }
    }

    deck.clear();
    for (ordered.cards.items) |c| try deck.addCard(c);
}

/// Creates a deep copy of the deck.
pub fn cloneDeck(alloc: std.mem.Allocator, deck: *Deck) !Deck {
    var clone = try Deck.init(alloc, deck.len());
    for (deck.cards.items) |c| try clone.addCard(c);
    return clone;
}

test "add standard deck" {
    const alloc = testing.allocator;

    var test_deck = try Deck.init(alloc, 108);
    defer test_deck.deinit();

    // deck with 52 cards, no jokers.
    try appendStandardDeck(&test_deck, 1, false);
    try testing.expectEqual(@as(usize, 52), test_deck.len());

    for (@intFromEnum(Card.Suit.Spade)..@intFromEnum(Card.Suit.Diamond) + 1) |suit| {
        for (@intFromEnum(Card.Rank.Ace)..@intFromEnum(Card.Rank.Two) + 1) |rank| {
            const card = Card{ .rank = @enumFromInt(rank), .suit = @enumFromInt(suit) };
            const exists = if (test_deck.tryLookupByCard(card)) |_| true else false;
            try testing.expect(exists);
        }
    }

    const joker = Card{ .rank = Card.Rank.Joker, .suit = Card.Suit.All };
    const exists = if (test_deck.tryLookupByCard(joker)) |_| true else false;
    try testing.expect(!exists);

    test_deck.clear();

    // deck with 52+52 cards, 2+2 jokers.
    try appendStandardDeck(&test_deck, 2, true);
    try testing.expectEqual(@as(usize, 108), test_deck.len());

    for (@intFromEnum(Card.Suit.Spade)..@intFromEnum(Card.Suit.Diamond) + 1) |suit| {
        for (@intFromEnum(Card.Rank.Ace)..@intFromEnum(Card.Rank.Two) + 1) |rank| {
            const identity = Card{ .rank = @enumFromInt(rank), .suit = @enumFromInt(suit) };
            const count = test_deck.countCardType(identity);

            try testing.expectEqual(@as(usize, 2), count);
        }
    }

    try testing.expectEqual(@as(usize, 4), test_deck.countCardType(joker));
}

test "transfer card" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    var test_deck_two = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();
    defer test_deck_two.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    try transferCardByIndex(&test_deck_one, 1, &test_deck_two);

    try testing.expectEqual(4, test_deck_two.len());
    try testing.expectEqual(test_deck_two.lookupByIndex(3), Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
}

test "transfer card by id" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    var test_deck_two = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();
    defer test_deck_two.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    // valid index
    try transferCardByID(&test_deck_one, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade }, &test_deck_two);

    try testing.expectEqual(4, test_deck_two.len());
    try testing.expectEqual(test_deck_two.lookupByIndex(3), Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
}

test "transfer random card" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    var test_deck_two = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();
    defer test_deck_two.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    try transferRandomCard(&test_deck_one, &test_deck_two);
    try testing.expectEqual(4, test_deck_two.len());
}

test "combine decks" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    var test_deck_two = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();
    defer test_deck_two.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_two.cards.append(test_deck_two.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    var test_deck_combined = try combineDecks(alloc, &test_deck_one, &test_deck_two);
    defer test_deck_combined.deinit();

    try testing.expectEqual(6, test_deck_combined.len());
}

test "order by suit" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart });

    try orderDeckBySuit(&test_deck_one);

    try testing.expectEqual(Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade }, test_deck_one.cards.items[0]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade }, test_deck_one.cards.items[1]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart }, test_deck_one.cards.items[2]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart }, test_deck_one.cards.items[3]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart }, test_deck_one.cards.items[4]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club }, test_deck_one.cards.items[5]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club }, test_deck_one.cards.items[6]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club }, test_deck_one.cards.items[7]);
    try testing.expectEqual(Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond }, test_deck_one.cards.items[8]);
    try testing.expectEqual(Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond }, test_deck_one.cards.items[9]);
}

test "order by rank ascending" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart });

    try orderDeckByRankAscending(&test_deck_one);

    const ace_club = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };
    const ace_spade = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const ace_heart = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const king_diamond = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond };
    const two_club = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const queen_heart = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart };
    const jack_spade = Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade };
    const five_diamond = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond };
    const seven_club = Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club };
    const three_heart = Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart };

    try testing.expectEqual(two_club.rank, test_deck_one.cards.items[0].rank);
    try testing.expectEqual(three_heart.rank, test_deck_one.cards.items[1].rank);
    try testing.expectEqual(five_diamond.rank, test_deck_one.cards.items[2].rank);
    try testing.expectEqual(seven_club.rank, test_deck_one.cards.items[3].rank);
    try testing.expectEqual(jack_spade.rank, test_deck_one.cards.items[4].rank);
    try testing.expectEqual(queen_heart.rank, test_deck_one.cards.items[5].rank);
    try testing.expectEqual(king_diamond.rank, test_deck_one.cards.items[6].rank);
    try testing.expectEqual(ace_club.rank, test_deck_one.cards.items[7].rank);
    try testing.expectEqual(ace_spade.rank, test_deck_one.cards.items[8].rank);
    try testing.expectEqual(ace_heart.rank, test_deck_one.cards.items[9].rank);
}

test "order by rank descending" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart });

    try orderDeckByRankDescending(&test_deck_one);

    const ace_club = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club };
    const ace_spade = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };
    const ace_heart = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const king_diamond = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond };
    const two_club = Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club };
    const queen_heart = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart };
    const jack_spade = Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade };
    const five_diamond = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond };
    const seven_club = Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club };
    const three_heart = Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart };

    try testing.expectEqual(ace_club.rank, test_deck_one.cards.items[0].rank);
    try testing.expectEqual(ace_spade.rank, test_deck_one.cards.items[1].rank);
    try testing.expectEqual(ace_heart.rank, test_deck_one.cards.items[2].rank);
    try testing.expectEqual(king_diamond.rank, test_deck_one.cards.items[3].rank);
    try testing.expectEqual(queen_heart.rank, test_deck_one.cards.items[4].rank);
    try testing.expectEqual(jack_spade.rank, test_deck_one.cards.items[5].rank);
    try testing.expectEqual(seven_club.rank, test_deck_one.cards.items[6].rank);
    try testing.expectEqual(five_diamond.rank, test_deck_one.cards.items[7].rank);
    try testing.expectEqual(three_heart.rank, test_deck_one.cards.items[8].rank);
    try testing.expectEqual(two_club.rank, test_deck_one.cards.items[9].rank);
}

test "clone deck" {
    const alloc = testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond });

    var cloned_deck = try cloneDeck(alloc, &test_deck_one);
    defer cloned_deck.deinit();

    try testing.expectEqual(test_deck_one.cards.items.len, cloned_deck.cards.items.len);

    try testing.expectEqual(test_deck_one.cards.items[0], cloned_deck.cards.items[0]);
    try testing.expectEqual(test_deck_one.cards.items[1], cloned_deck.cards.items[1]);
    try testing.expectEqual(test_deck_one.cards.items[2], cloned_deck.cards.items[2]);
    try testing.expectEqual(test_deck_one.cards.items[3], cloned_deck.cards.items[3]);
}
