//! Utility functions for card classification and string conversions.
const std = @import("std");
const Card = @import("card.zig");
const testing = std.testing;
const debug = std.debug;

/// Returns true if the card is a face card.
pub fn isFaceCard(card: Card) bool {
    return switch (card.rank) {
        .Jack, .Queen, .King, .All => true,
        else => false,
    };
}

/// Returns true if the card is a face card or an Ace.
pub fn isAceOrFaceCard(card: Card) bool {
    return switch (card.rank) {
        .Ace, .Jack, .Queen, .King, .All => true,
        else => false,
    };
}

/// Converts a card to a 2-byte string, e.g. `AH`, `9C`. Returns null on invalid input.
pub fn cardToString(card: Card) ?[2]u8 {
    const r: ?u8 = switch (card.rank) {
        .Ace => 'A',
        .King => 'K',
        .Queen => 'Q',
        .Jack => 'J',
        .Ten => 'T',
        .Nine => '9',
        .Eight => '8',
        .Seven => '7',
        .Six => '6',
        .Five => '5',
        .Four => '4',
        .Three => '3',
        .Two => '2',
        else => return null,
    };

    const s: ?u8 = switch (card.suit) {
        .Heart => 'H',
        .Club => 'C',
        .Diamond => 'D',
        .Spade => 'S',
        .All => 'A',
        else => return null,
    };

    if (r == null or s == null) return null;
    return .{ r.?, s.? };
}

/// Parses a 2-byte card string like `"9C"` or `"AH"`. Returns null on invalid input.
pub fn parseCard(str: []const u8) ?Card {
    if (str.len != 2) return null;

    const r = str[0];
    const su = str[1];

    const rank = switch (r) {
        'A' => Card.Rank.Ace,
        'K' => Card.Rank.King,
        'Q' => Card.Rank.Queen,
        'J' => Card.Rank.Jack,
        'T' => Card.Rank.Ten,
        '9' => Card.Rank.Nine,
        '8' => Card.Rank.Eight,
        '7' => Card.Rank.Seven,
        '6' => Card.Rank.Six,
        '5' => Card.Rank.Five,
        '4' => Card.Rank.Four,
        '3' => Card.Rank.Three,
        '2' => Card.Rank.Two,
        else => Card.Rank.Invalid,
    };

    const suit = switch (su) {
        'H' => Card.Suit.Heart,
        'C' => Card.Suit.Club,
        'D' => Card.Suit.Diamond,
        'S' => Card.Suit.Spade,
        'A' => Card.Suit.All,
        else => Card.Suit.Invalid,
    };

    if (rank == Card.Rank.Invalid or suit == Card.Suit.Invalid) return null;

    return Card{ .rank = rank, .suit = suit };
}

test "is face card" {
    const card_one = Card{
        .rank = Card.Rank.King,
        .suit = Card.Suit.Spade,
    };
    const card_two = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade };
    const card_four = Card{ .rank = Card.Rank.All, .suit = Card.Suit.Spade };
    const card_five = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Spade };

    try testing.expect(isFaceCard(card_one));
    try testing.expect(isFaceCard(card_two));
    try testing.expect(isFaceCard(card_three));
    try testing.expect(isFaceCard(card_four));
    try testing.expect(!isFaceCard(card_five));
}

test "is face card or ace" {
    const card_one = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade };
    const card_four = Card{ .rank = Card.Rank.All, .suit = Card.Suit.Spade };
    const card_five = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Spade };
    const card_six = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    try testing.expect(isAceOrFaceCard(card_one));
    try testing.expect(isAceOrFaceCard(card_two));
    try testing.expect(isAceOrFaceCard(card_three));
    try testing.expect(isAceOrFaceCard(card_four));
    try testing.expect(!isAceOrFaceCard(card_five));
    try testing.expect(isAceOrFaceCard(card_six));
}

test "card to string" {
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };

    const card_string = cardToString(card_one).?;
    const expected_string = [2]u8{ 'A', 'H' };

    try testing.expectEqual(expected_string, card_string);
}

test "invalid card to string" {
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Invalid };

    const card_string: ?[2]u8 = cardToString(card_one);
    const expected_string = null;

    try testing.expectEqual(expected_string, card_string);
}

test "parse card" {
    const string_one = "AH";
    const string_two = "TC";
    const string_three = "6D";

    const expected_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };
    const expected_two = Card{ .rank = Card.Rank.Ten, .suit = Card.Suit.Club };
    const expected_three = Card{ .rank = Card.Rank.Six, .suit = Card.Suit.Diamond };

    const parsed_one = parseCard(string_one).?;
    const parsed_two = parseCard(string_two).?;
    const parsed_three = parseCard(string_three).?;

    try testing.expectEqual(expected_one, parsed_one);
    try testing.expectEqual(expected_two, parsed_two);
    try testing.expectEqual(expected_three, parsed_three);
}

test "invalid string card" {
    const string_one = "1F";

    const expected_one = null;

    const parsed_one: ?Card = parseCard(string_one);

    try testing.expectEqual(expected_one, parsed_one);
}
