const std = @import("std");

/// Suits used for the cards.
pub const Suit = enum(u4) {
    Empty,
    Heart,
    Spade,
    Club,
    Diamond,

    /// Checks if the suits are equal.
    pub fn isSuitEqual(current_suit: Suit, desired_suit: Suit) bool {
        return if (current_suit == desired_suit) true else false;
    }
};

/// Ranks used for the cards.
pub const Rank = enum(u4) {
    Empty,
    Joker,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King,
    Ace,

    /// Checks if the ranks are equal.
    pub fn isRankEqual(current_rank: Rank, desired_rank: Rank) bool {
        return if (current_rank == desired_rank) true else false;
    }
};

/// Card indentity attributes for Rank and Suit.
pub const Identity = struct {
    rank: Rank,
    suit: Suit,

    pub fn isCardEqual(card_one: Identity, card_two: Identity) bool {
        return if (card_one.rank == card_two.rank and card_one.suit == card_two.suit) true else false;
    }

    /// Sets the card's rank.
    pub fn changeRank(self: *Identity, newRank: Rank) void {
        self.rank = newRank;
    }

    /// Sets the card's suit.
    pub fn changeSuit(self: *Identity, newSuit: Suit) void {
        self.suit = newSuit;
    }
};

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
    const card_one = Identity{ .rank = Rank.Ace, .suit = Suit.Club };
    const card_two = Identity{ .rank = Rank.Ace, .suit = Suit.Club };

    try std.testing.expect(Identity.isCardEqual(card_one, card_two));
}

test "equal card false" {
    const card_one = Identity{ .rank = Rank.Ace, .suit = Suit.Club };
    const card_two = Identity{ .rank = Rank.Ace, .suit = Suit.Heart };

    try std.testing.expect(!Identity.isCardEqual(card_one, card_two));
}

test "change rank" {
    var card_one = Identity{ .rank = Rank.Ace, .suit = Suit.Club };

    card_one.changeRank(Rank.Eight);

    try std.testing.expect(Rank.Eight == card_one.rank);
}

test "change suit" {
    var card_one = Identity{ .rank = Rank.Ace, .suit = Suit.Club };

    card_one.changeSuit(Suit.Spade);

    try std.testing.expect(Suit.Spade == card_one.suit);
}
