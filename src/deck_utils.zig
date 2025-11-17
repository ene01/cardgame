//! Deck functions that do a bit too much to be inside the deck module.
const Deck = @import("deck.zig");
const Card = @import("card.zig");
const std = @import("std");

/// Adds a standard 52 deck of cards to the deck, you can specify to add multiple standard decks.
pub fn appendStandardDeck(d: *Deck, times: usize, jokers: bool) !void {
    for (0..times) |_| {
        for (2..(@intFromEnum(Card.Suit.Diamond)) + 1) |suitInt| { // Begin from Club to Spades
            for (3..(@intFromEnum(Card.Rank.Two)) + 1) |rankInt| { // From Ace to
                try d.addCard(Card{ .rank = @enumFromInt(rankInt), .suit = @enumFromInt(suitInt) });
            }
        }

        // 2 per 52 cards.
        if (jokers) {
            try d.addCard(Card{ .rank = Card.Rank.Joker, .suit = Card.Suit.All });
            try d.addCard(Card{ .rank = Card.Rank.Joker, .suit = Card.Suit.All });
        }
    }
}

/// Returns a random picked card from the deck then removes it.
pub fn dealCard(d: *Deck, seed: ?u64) ?Card {
    const picked_card = d.randomLookUp(seed);

    if (picked_card) |valid_card| {
        _ = d.removeCardByID(valid_card);
    }

    return picked_card;
}

/// Transfers a selected card from deck to deck, removes the card from the sender.
pub fn transferCard(from: *Deck, index_from: usize, to: *Deck) !void {
    const card_to_transfer = from.lookUpByIndex(index_from);

    if (card_to_transfer) |valid_card| {
        try to.addCard(valid_card);
        _ = from.removeCardByIndex(index_from); // TODO: this feels weird, this returns something but we just discard it?, sure :3
    }
}

/// Transfers a random card from deck to deck, removes the card from the sender.
pub fn transferRandomCard(from: *Deck, to: *Deck) !void {
    var rng = std.Random.DefaultPrng.init(@intCast(std.time.nanoTimestamp()));
    const random_number = rng.random().uintLessThan(usize, from.len());

    const card_to_transfer = from.lookUpByIndex(random_number);

    if (card_to_transfer) |valid_card| {
        try to.addCard(valid_card);
        _ = from.removeCardByIndex(random_number);
    }
}

/// Returns a combination of two decks.
pub fn combineDecks(alloc: std.mem.Allocator, deck_one: *Deck, deck_two: *Deck) !Deck {
    var combined_deck = try Deck.init(alloc, deck_one.len() + deck_two.len());

    for (deck_one.cards.items) |current_card| {
        try combined_deck.addCard(current_card);
    }

    for (deck_two.cards.items) |current_card| {
        try combined_deck.addCard(current_card);
    }

    return combined_deck;
}

/// Orders the cards by their suit, each ordered suit is also ordered by rank.
pub fn orderDeckBySuit(d: *Deck) !void {
    const alloc = std.heap.page_allocator;
    var ordered_deck = try Deck.init(alloc, d.len());
    defer ordered_deck.deinit();

    var counter: u16 = 0;

    for (1..(@intFromEnum(Card.Suit.Diamond)) + 1) |suit_int| {
        for (1..(@intFromEnum(Card.Rank.Two)) + 1) |rank_int| {
            const current_card = Card{ .rank = @enumFromInt(rank_int), .suit = @enumFromInt(suit_int) };

            if (d.cardExists(current_card)) {
                try ordered_deck.addCard(current_card);
                counter += 1;
                if (counter == d.len()) break; // No more cards to order.
            }
        }
    }

    d.clear();

    // Re-add all cards but in order.
    for (ordered_deck.cards.items) |current_card| {
        try d.addCard(current_card);
    }
}

/// Orders the cards by their rank in descending order (Ace to Two)
pub fn orderDeckByRankDescending(d: *Deck) !void {
    const alloc = std.heap.page_allocator;
    var ordered_deck = try Deck.init(alloc, d.len());
    defer ordered_deck.deinit();

    var counter: u16 = 0;

    for (1..(@intFromEnum(Card.Rank.Two)) + 1) |rankInt| {
        for (1..(@intFromEnum(Card.Suit.Diamond)) + 1) |suitInt| {
            const current_card = Card{ .rank = @enumFromInt(rankInt), .suit = @enumFromInt(suitInt) };

            if (d.cardExists(current_card)) {
                try ordered_deck.addCard(current_card);
                counter += 1;
                if (counter == d.len()) break; // No more cards to order.
            }
        }
    }

    d.clear();

    // Re-add all cards but in order.
    for (ordered_deck.cards.items) |current_card| {
        try d.addCard(current_card);
    }
}

/// Orders the cards by their rank in ascending order (Two to Ace)
pub fn orderDeckByRankAscending(d: *Deck) !void {
    const alloc = std.heap.page_allocator;
    var ordered_deck = try Deck.init(alloc, d.len());
    defer ordered_deck.deinit();

    var counter: u16 = 0;

    var rank_int: u8 = @intFromEnum(Card.Rank.Two);
    while (rank_int + 1 > 1) : (rank_int -= 1) {
        for (1..(@intFromEnum(Card.Suit.Diamond)) + 1) |suit_int| {
            const current_card = Card{ .rank = @enumFromInt(rank_int), .suit = @enumFromInt(suit_int) };

            if (d.cardExists(current_card)) {
                try ordered_deck.addCard(current_card);
                counter += 1;
                if (counter == d.len()) break; // No more cards to order.
            }
        }
    }

    d.clear();

    // Re-add all cards but in order.
    for (ordered_deck.cards.items) |current_card| {
        try d.addCard(current_card);
    }
}

/// Returns a perfect clone of a deck.
pub fn cloneDeck(alloc: std.mem.Allocator, d: *Deck) !Deck {
    const card_amount = d.len();
    var cloned_deck = try Deck.init(alloc, card_amount);

    for (d.cards.items) |current_card| {
        try cloned_deck.addCard(current_card);
    }

    return cloned_deck;
}

test "add standard deck" {
    const alloc = std.testing.allocator;

    var test_deck = try Deck.init(alloc, 108);
    defer test_deck.deinit();

    // deck with 52 cards, no jokers.
    try appendStandardDeck(&test_deck, 1, false);
    try std.testing.expectEqual(@as(usize, 52), test_deck.len());

    for (@intFromEnum(Card.Suit.Spade)..@intFromEnum(Card.Suit.Diamond) + 1) |suit| {
        for (@intFromEnum(Card.Rank.Ace)..@intFromEnum(Card.Rank.Two) + 1) |rank| {
            const identity = Card{ .rank = @enumFromInt(rank), .suit = @enumFromInt(suit) };
            try std.testing.expect(test_deck.cardExists(identity));
        }
    }

    try std.testing.expect(!test_deck.cardExists(Card{
        .rank = Card.Rank.Joker,
        .suit = Card.Suit.All,
    }));

    test_deck.clear();

    // deck with 52+52 cards, 2+2 jokers.
    try appendStandardDeck(&test_deck, 2, true);
    try std.testing.expectEqual(@as(usize, 108), test_deck.len());

    for (@intFromEnum(Card.Suit.Spade)..@intFromEnum(Card.Suit.Diamond) + 1) |suit| {
        for (@intFromEnum(Card.Rank.Ace)..@intFromEnum(Card.Rank.Two) + 1) |rank| {
            const identity = Card{ .rank = @enumFromInt(rank), .suit = @enumFromInt(suit) };
            const count = test_deck.countCardType(identity);

            try std.testing.expectEqual(@as(usize, 2), count);
        }
    }

    const joker = Card{ .rank = Card.Rank.Joker, .suit = Card.Suit.All };
    try std.testing.expectEqual(@as(usize, 4), test_deck.countCardType(joker));
}

test "deal card" {
    const alloc = std.testing.allocator;

    var test_deck = try Deck.init(alloc, 4);
    defer test_deck.deinit();

    try test_deck.cards.append(test_deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck.cards.append(test_deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck.cards.append(test_deck.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });

    // if this was null, then the deck would not have an extra card anyways.
    _ = dealCard(&test_deck, null);

    try std.testing.expectEqual(2, test_deck.cards.items.len);
}

test "transfer card" {
    const alloc = std.testing.allocator;

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

    // invalid index
    try transferCard(&test_deck_one, 6, &test_deck_two);
    try std.testing.expectEqual(3, test_deck_two.cards.items.len);

    // valid index
    try transferCard(&test_deck_one, 1, &test_deck_two);

    try std.testing.expectEqual(4, test_deck_two.cards.items.len);
    try std.testing.expectEqual(test_deck_two.cards.items[3], Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
}

test "transfer random card" {
    const alloc = std.testing.allocator;

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
    try std.testing.expectEqual(4, test_deck_two.cards.items.len);
}

test "combine decks" {
    const alloc = std.testing.allocator;

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

    try std.testing.expectEqual(6, test_deck_combined.cards.items.len);
}

test "order by suit" {
    const alloc = std.testing.allocator;

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

    try std.testing.expectEqual(Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade }, test_deck_one.cards.items[0]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade }, test_deck_one.cards.items[1]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart }, test_deck_one.cards.items[2]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Heart }, test_deck_one.cards.items[3]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Three, .suit = Card.Suit.Heart }, test_deck_one.cards.items[4]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club }, test_deck_one.cards.items[5]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Seven, .suit = Card.Suit.Club }, test_deck_one.cards.items[6]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Two, .suit = Card.Suit.Club }, test_deck_one.cards.items[7]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond }, test_deck_one.cards.items[8]);
    try std.testing.expectEqual(Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Diamond }, test_deck_one.cards.items[9]);
}

test "order by rank ascending" {
    const alloc = std.testing.allocator;

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

    try std.testing.expectEqual(two_club.rank, test_deck_one.cards.items[0].rank);
    try std.testing.expectEqual(three_heart.rank, test_deck_one.cards.items[1].rank);
    try std.testing.expectEqual(five_diamond.rank, test_deck_one.cards.items[2].rank);
    try std.testing.expectEqual(seven_club.rank, test_deck_one.cards.items[3].rank);
    try std.testing.expectEqual(jack_spade.rank, test_deck_one.cards.items[4].rank);
    try std.testing.expectEqual(queen_heart.rank, test_deck_one.cards.items[5].rank);
    try std.testing.expectEqual(king_diamond.rank, test_deck_one.cards.items[6].rank);
    try std.testing.expectEqual(ace_club.rank, test_deck_one.cards.items[7].rank);
    try std.testing.expectEqual(ace_spade.rank, test_deck_one.cards.items[8].rank);
    try std.testing.expectEqual(ace_heart.rank, test_deck_one.cards.items[9].rank);
}

test "order by rank descending" {
    const alloc = std.testing.allocator;

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

    try std.testing.expectEqual(ace_club.rank, test_deck_one.cards.items[0].rank);
    try std.testing.expectEqual(ace_spade.rank, test_deck_one.cards.items[1].rank);
    try std.testing.expectEqual(ace_heart.rank, test_deck_one.cards.items[2].rank);
    try std.testing.expectEqual(king_diamond.rank, test_deck_one.cards.items[3].rank);
    try std.testing.expectEqual(queen_heart.rank, test_deck_one.cards.items[4].rank);
    try std.testing.expectEqual(jack_spade.rank, test_deck_one.cards.items[5].rank);
    try std.testing.expectEqual(seven_club.rank, test_deck_one.cards.items[6].rank);
    try std.testing.expectEqual(five_diamond.rank, test_deck_one.cards.items[7].rank);
    try std.testing.expectEqual(three_heart.rank, test_deck_one.cards.items[8].rank);
    try std.testing.expectEqual(two_club.rank, test_deck_one.cards.items[9].rank);
}

test "clone deck" {
    const alloc = std.testing.allocator;

    var test_deck_one = try Deck.init(alloc, 10);
    defer test_deck_one.deinit();

    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Club });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart });
    try test_deck_one.cards.append(test_deck_one.allocator, Card{ .rank = Card.Rank.King, .suit = Card.Suit.Diamond });

    var cloned_deck = try cloneDeck(alloc, &test_deck_one);
    defer cloned_deck.deinit();

    try std.testing.expectEqual(test_deck_one.cards.items.len, cloned_deck.cards.items.len);

    try std.testing.expectEqual(test_deck_one.cards.items[0], cloned_deck.cards.items[0]);
    try std.testing.expectEqual(test_deck_one.cards.items[1], cloned_deck.cards.items[1]);
    try std.testing.expectEqual(test_deck_one.cards.items[2], cloned_deck.cards.items[2]);
    try std.testing.expectEqual(test_deck_one.cards.items[3], cloned_deck.cards.items[3]);
}
