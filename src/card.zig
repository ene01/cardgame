const std = @import("std");
const rank = @import("rank.zig");
const suit = @import("suit.zig");

/// Card attributes: Rank and Suit.
pub const Identity = struct {
    rank: rank.Hierarchy,
    suit: suit.Group,

    pub fn isCardEqual(cardOne: Identity, cardTwo: Identity) bool {
        return if (cardOne.rank == cardTwo.rank and cardOne.suit == cardTwo.suit) true else false;
    }

    /// Sets the card's rank.
    pub fn changeRank(self: *Identity, newRank: rank.Hierarchy) void {
        self.rank = newRank;
    }

    /// Sets the card's suit.
    pub fn changeSuit(self: *Identity, newSuit: suit.Group) void {
        self.suit = newSuit;
    }
};
