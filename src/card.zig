//! Card definitions.
const std = @import("std");
const log = @import("log.zig");
const testing = std.testing;

/// Suits for cards.
pub const Suit = enum(u4) {
    /// Placeholder for invalid cards.
    Invalid,
    All,
    Spade,
    Heart,
    Club,
    Diamond,

    /// Returns true when both suits match.
    pub fn isSuitEqual(current_suit: Suit, desired_suit: Suit) bool {
        return current_suit == desired_suit;
    }
};

/// Ranks for cards.
pub const Rank = enum(u8) {
    /// Placeholder for invalid cards.
    Invalid,
    All,
    Joker,
    Ace,
    King,
    Queen,
    Jack,
    Ten,
    Nine,
    Eight,
    Seven,
    Six,
    Five,
    Four,
    Three,
    Two,

    /// Returns true when both ranks match.
    pub fn isRankEqual(current_rank: Rank, desired_rank: Rank) bool {
        return current_rank == desired_rank;
    }

    /// Returns true when the expected `higher` rank is above the expected `lower`.
    pub fn isRankHigherThan(exp_higher: Rank, exp_lower: Rank) bool {
        return @intFromEnum(exp_higher) < @intFromEnum(exp_lower);
    }

    /// Returns true when the expected `lower` rank is below the expected `higher`.
    pub fn isRankLowerThan(exp_lower: Rank, exp_higher: Rank) bool {
        return @intFromEnum(exp_lower) > @intFromEnum(exp_higher);
    }

    /// Returns true when `candidate` is exactly one rank above `current`.
    pub fn isRankOneHigher(candidate: Rank, current: Rank) bool {
        return @intFromEnum(candidate) == @intFromEnum(current) - 1;
    }

    /// Returns true when `candidate` is exactly one rank below `current`.
    pub fn isRankOneLower(candidate: Rank, current: Rank) bool {
        return @intFromEnum(candidate) == @intFromEnum(current) + 1;
    }
};

/// Card with a `Rank` and `Suit`.
pub const Card = @This();

rank: Rank,
suit: Suit,

/// Returns true when rank and suit both match.
pub fn isCardEqual(card_one: Card, card_two: Card) bool {
    return card_one.rank == card_two.rank and card_one.suit == card_two.suit;
}

/// Updates the card's rank.
pub fn changeRank(self: *Card, new_rank: Rank) void {
    self.rank = new_rank;

    if (new_rank == .Invalid) {
        log.warn(@src(), "This card has been set as an invalid rank: '{}'", .{self});
    }
}

/// Updates the card's suit.
pub fn changeSuit(self: *Card, new_suit: Suit) void {
    self.suit = new_suit;

    if (new_suit == .Invalid) {
        log.warn(@src(), "This card has been set as an invalid suit: '{}'", .{self});
    }
}

test "equal rank true" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.Ace;

    try testing.expect(Rank.isRankEqual(rank_one, rank_two));
}

test "equal rank false" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.King;

    try testing.expect(!Rank.isRankEqual(rank_one, rank_two));
}

test "rank higher than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.Two;

    try testing.expect(Rank.isRankHigherThan(rank_one, rank_two));
}

test "rank lower than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.Two;

    try testing.expect(Rank.isRankLowerThan(rank_two, rank_one));
}

test "rank one higher than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.King;

    try testing.expect(Rank.isRankOneHigher(rank_one, rank_two));
}

test "rank one lower than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.King;

    try testing.expect(Rank.isRankOneLower(rank_two, rank_one));
}

test "equal suit true" {
    const suit_one = Suit.Club;
    const suit_two = Suit.Club;

    try testing.expect(Suit.isSuitEqual(suit_one, suit_two));
}

test "equal suit false" {
    const suit_one = Suit.Club;
    const suit_two = Suit.Spade;

    try testing.expect(!Suit.isSuitEqual(suit_one, suit_two));
}

test "equal card true" {
    const card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };
    const card_two = Card{ .rank = Rank.Ace, .suit = Suit.Club };

    try testing.expect(Card.isCardEqual(card_one, card_two));
}

test "equal card false" {
    const card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };
    const card_two = Card{ .rank = Rank.Ace, .suit = Suit.Heart };

    try testing.expect(!Card.isCardEqual(card_one, card_two));
}

test "change rank" {
    var card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };

    card_one.changeRank(Rank.Eight);

    try testing.expect(Rank.Eight == card_one.rank);
}

test "change suit" {
    var card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };

    card_one.changeSuit(Suit.Spade);

    try testing.expect(Suit.Spade == card_one.suit);
}
