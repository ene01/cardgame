const std = @import("std");
const Card = @import("card.zig");

/// Checks if the card counts as a face card.
pub fn isFaceCard(c: Card) bool {
    return switch (c.rank) {
        .Jack, .Queen, .King, .All => true,
        else => false,
    };
}

/// Checks if the card counts as a face card or an Ace.
pub fn isAceOrFaceCard(c: Card) bool {
    return switch (c.rank) {
        .Ace, .Jack, .Queen, .King, .All => true,
        else => false,
    };
}

/// Converts a card identity into a string equivalent.
pub fn cardToString(c: Card) ?[2]u8 {
    const r: ?u8 = switch (c.rank) {
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

    const s: ?u8 = switch (c.suit) {
        .Heart => 'H',
        .Club => 'C',
        .Diamond => 'D',
        .Spade => 'S',
        .All => 'A',
        else => return null,
    };

    if (r == null or s == null) {
        return null;
    } else {
        return .{ r.?, s.? };
    }
}

/// Converts a string into a valid card identity, format used is a letter for the suit and a letter for the rank,
/// suits are "S, H, C, D", and ranks are "A, K, Q, J, T, 9 to 2". An example of a valid card would be "9C" (Nine of clubs).
pub fn parseCard(s: []const u8) ?Card {
    if (s.len != 2) return null;

    const r = s[0];
    const su = s[1];

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

    if (rank == Card.Rank.Invalid or suit == Card.Suit.Invalid) {
        return null;
    } else {
        return Card{
            .rank = rank,
            .suit = suit,
        };
    }
}

test "is face card" {
    const card_one = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade };
    const card_four = Card{ .rank = Card.Rank.All, .suit = Card.Suit.Spade };
    const card_five = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Spade };

    try std.testing.expect(isFaceCard(card_one));
    try std.testing.expect(isFaceCard(card_two));
    try std.testing.expect(isFaceCard(card_three));
    try std.testing.expect(isFaceCard(card_four));
    try std.testing.expect(!isFaceCard(card_five));
}

test "is face card or ace" {
    const card_one = Card{ .rank = Card.Rank.King, .suit = Card.Suit.Spade };
    const card_two = Card{ .rank = Card.Rank.Queen, .suit = Card.Suit.Spade };
    const card_three = Card{ .rank = Card.Rank.Jack, .suit = Card.Suit.Spade };
    const card_four = Card{ .rank = Card.Rank.All, .suit = Card.Suit.Spade };
    const card_five = Card{ .rank = Card.Rank.Five, .suit = Card.Suit.Spade };
    const card_six = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Spade };

    try std.testing.expect(isAceOrFaceCard(card_one));
    try std.testing.expect(isAceOrFaceCard(card_two));
    try std.testing.expect(isAceOrFaceCard(card_three));
    try std.testing.expect(isAceOrFaceCard(card_four));
    try std.testing.expect(!isAceOrFaceCard(card_five));
    try std.testing.expect(isAceOrFaceCard(card_six));
}

test "card to string" {
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Heart };

    const card_string = cardToString(card_one).?;
    const expected_string = [2]u8{ 'A', 'H' };

    try std.testing.expectEqual(expected_string, card_string);
}

test "invalid card to string" {
    const card_one = Card{ .rank = Card.Rank.Ace, .suit = Card.Suit.Invalid };

    const card_string: ?[2]u8 = cardToString(card_one);
    const expected_string = null;

    try std.testing.expectEqual(expected_string, card_string);
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

    try std.testing.expectEqual(expected_one, parsed_one);
    try std.testing.expectEqual(expected_two, parsed_two);
    try std.testing.expectEqual(expected_three, parsed_three);
}

test "invalid string card" {
    const string_one = "1F";

    const expected_one = null;

    const parsed_one: ?Card = parseCard(string_one);

    try std.testing.expectEqual(expected_one, parsed_one);
}
