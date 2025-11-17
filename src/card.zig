//! The card definitnion.
const std = @import("std");

/// Suits used for the cards.
pub const Suit = enum(u8) {
    /// Mainly intended as a placeholder for error cards.
    Invalid,
    All,
    Spade,
    Heart,
    Club,
    Diamond,

    /// Checks if the suits are equal.
    pub fn isSuitEqual(current_suit: Suit, desired_suit: Suit) bool {
        return if (current_suit == desired_suit) true else false;
    }
};

/// Ranks used for the cards.
pub const Rank = enum(u8) {
    /// Mainly intended as a placeholder for error cards.
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

    /// Checks if the ranks are equal.
    pub fn isRankEqual(current_rank: Rank, desired_rank: Rank) bool {
        return if (current_rank == desired_rank) true else false;
    }

    /// Checks if the `Rank` given is higher than another `Rank`.
    pub fn isRankHigherThan(higher: Rank, lower: Rank) bool {
        return if (@intFromEnum(higher) < @intFromEnum(lower)) true else false;
    }

    /// Checks if the `Rank` given is lower than another `Rank`.
    pub fn isRankLowerThan(lower: Rank, higher: Rank) bool {
        return if (@intFromEnum(lower) > @intFromEnum(higher)) true else false;
    }

    /// Checks if a `Rank` is one higher than another `Rank`.
    pub fn isRankOneHigher(candidate: Rank, current: Rank) bool {
        return if (@intFromEnum(candidate) == @intFromEnum(current) - 1) true else false;
    }

    /// Checks if a `Rank` is one lower than another `Rank`.
    pub fn isRankOneLower(candidate: Rank, current: Rank) bool {
        return if (@intFromEnum(candidate) == @intFromEnum(current) + 1) true else false;
    }
};

/// Card attributes, defines `Rank` and `Suit` for a card.
pub const Card = @This();

rank: Rank,
suit: Suit,

pub fn isCardEqual(card_one: Card, card_two: Card) bool {
    return if (card_one.rank == card_two.rank and card_one.suit == card_two.suit) true else false;
}

/// Sets the card's rank.
pub fn changeRank(self: *Card, newRank: Rank) void {
    self.rank = newRank;
}

/// Sets the card's suit.
pub fn changeSuit(self: *Card, newSuit: Suit) void {
    self.suit = newSuit;
}

test "equal rank true" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.Ace;

    try std.testing.expect(Rank.isRankEqual(rank_one, rank_two));
}

test "equal rank false" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.King;

    try std.testing.expect(!Rank.isRankEqual(rank_one, rank_two));
}

test "rank higher than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.Two;

    try std.testing.expect(Rank.isRankHigherThan(rank_one, rank_two));
}

test "rank lower than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.Two;

    try std.testing.expect(Rank.isRankLowerThan(rank_two, rank_one));
}

test "rank one higher than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.King;

    try std.testing.expect(Rank.isRankOneHigher(rank_one, rank_two));
}

test "rank one lower than" {
    const rank_one = Rank.Ace;
    const rank_two = Rank.King;

    try std.testing.expect(Rank.isRankOneLower(rank_two, rank_one));
}

test "equal suit true" {
    const suit_one = Suit.Club;
    const suit_two = Suit.Club;

    try std.testing.expect(Suit.isSuitEqual(suit_one, suit_two));
}

test "equal suit false" {
    const suit_one = Suit.Club;
    const suit_two = Suit.Spade;

    try std.testing.expect(!Suit.isSuitEqual(suit_one, suit_two));
}

test "equal card true" {
    const card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };
    const card_two = Card{ .rank = Rank.Ace, .suit = Suit.Club };

    try std.testing.expect(Card.isCardEqual(card_one, card_two));
}

test "equal card false" {
    const card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };
    const card_two = Card{ .rank = Rank.Ace, .suit = Suit.Heart };

    try std.testing.expect(!Card.isCardEqual(card_one, card_two));
}

test "change rank" {
    var card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };

    card_one.changeRank(Rank.Eight);

    try std.testing.expect(Rank.Eight == card_one.rank);
}

test "change suit" {
    var card_one = Card{ .rank = Rank.Ace, .suit = Suit.Club };

    card_one.changeSuit(Suit.Spade);

    try std.testing.expect(Suit.Spade == card_one.suit);
}
