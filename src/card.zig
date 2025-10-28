const std = @import("std");
const rank = @import("rank.zig");
const suit = @import("suit.zig");

/// Card attributes: Rank and Suit.
pub const CAttributes = struct {
    rank: rank.Hierarchy,
    suit: suit.Group,

    /// Sets the card's rank.
    pub fn changeRank(self: *CAttributes, newRank: rank.Hierarchy) void {
        self.rank = newRank;
    }

    /// Sets the card's suit.
    pub fn changeSuit(self: *CAttributes, newSuit: suit.Group) void {
        self.suit = newSuit;
    }
};
