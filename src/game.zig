const std = @import("std");
const deck = @import("deck.zig");
const player = @import("player.zig");
const rank = @import("rank.zig");
const suit = @import("suit.zig");
const card = @import("card.zig");

/// Initiation of Cardgame.
pub fn init(alloc: std.mem.Allocator) Cardgame {
    return Cardgame{ .deck = deck.init(alloc), .player = player.init(alloc) };
}

// TODO: Needs the game implementation itself...
pub const Cardgame = struct {
    deck: deck.Cards,
    player: player.PAttributes,

    pub fn giveCardsToPlayer(self: *Cardgame) !void {
        for (self.player.hand.items.len..5) |_| {
            const picked_card = try self.deck.randomLookUp();

            try self.player.addToHand(picked_card);
            try self.deck.removeSingleCard(picked_card);
        }
    }

    /// Deinit allocator data.
    pub fn deinit(self: *Cardgame) !void {
        self.deck.deinit();
        self.player.deinit();
    }

    /// Adds a standard 52+52 deck of cards for the game.
    pub fn addStandardDeck(self: *Cardgame) !void {
        for (0..2) |_| { // Repeat 2 times
            for (1..(@intFromEnum(suit.Group.Diamond)) + 1) |suitInt| {
                for (2..(@intFromEnum(rank.Hierarchy.Ace)) + 1) |rankInt| {
                    try self.deck.addCard(card.CAttributes{ .rank = @enumFromInt(rankInt), .suit = @enumFromInt(suitInt) });
                }
            }
        }
    }
};
