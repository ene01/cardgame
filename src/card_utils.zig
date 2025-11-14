const std = @import("std");
const card = @import("card.zig");

/// Checks if the card counts as a face card.
pub fn isFaceCard(c: card.Identity) bool {
    return switch (c.rank) {
        .Jack, .Queen, .King, .All => true,
        else => false,
    };
}

/// Checks if the card counts as a face card or an Ace.
pub fn isAceOrFaceCard(c: card.Identity) bool {
    return switch (c.rank) {
        .Ace, .Jack, .Queen, .King, .All => true,
        else => false,
    };
}

/// Converts a card identity into a string equivalent.
pub fn cardToString(c: card.Identity) ?[2]u8 {
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
pub fn parseCard(s: []const u8) ?card.Identity {
    if (s.len != 2) return null;

    const r = s[0];
    const su = s[1];

    const rank = switch (r) {
        'A' => card.Rank.Ace,
        'K' => card.Rank.King,
        'Q' => card.Rank.Queen,
        'J' => card.Rank.Jack,
        'T' => card.Rank.Ten,
        '9' => card.Rank.Nine,
        '8' => card.Rank.Eight,
        '7' => card.Rank.Seven,
        '6' => card.Rank.Six,
        '5' => card.Rank.Five,
        '4' => card.Rank.Four,
        '3' => card.Rank.Three,
        '2' => card.Rank.Two,
        else => card.Rank.Invalid,
    };

    const suit = switch (su) {
        'H' => card.Suit.Heart,
        'C' => card.Suit.Club,
        'D' => card.Suit.Diamond,
        'S' => card.Suit.Spade,
        'A' => card.Suit.All,
        else => card.Suit.Invalid,
    };

    if (rank == card.Rank.Invalid or suit == card.Suit.Invalid) {
        return null;
    } else {
        return card.Identity{
            .rank = rank,
            .suit = suit,
        };
    }
}

test "card to string" {
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };

    const card_string = cardToString(card_one).?;
    const expected_string = [2]u8{ 'A', 'H' };

    try std.testing.expectEqual(expected_string, card_string);
}

test "invalid card to string" {
    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Invalid };

    const card_string: ?[2]u8 = cardToString(card_one);
    const expected_string = null;

    try std.testing.expectEqual(expected_string, card_string);
}

test "parse card" {
    const string_one = "AH";
    const string_two = "TC";
    const string_three = "6D";

    const expected_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const expected_two = card.Identity{ .rank = card.Rank.Ten, .suit = card.Suit.Club };
    const expected_three = card.Identity{ .rank = card.Rank.Six, .suit = card.Suit.Diamond };

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

    const parsed_one: ?card.Identity = parseCard(string_one);

    try std.testing.expectEqual(expected_one, parsed_one);
}
