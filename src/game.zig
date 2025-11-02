const std = @import("std");
const deck = @import("deck.zig");
const player = @import("player.zig");
const rank = @import("rank.zig");
const suit = @import("suit.zig");
const card = @import("card.zig");

// TODO: Needs the game implementation itself...
pub const Cardgame = struct {
    deck: deck.PlayingCards,
    player: player.Attributes,

    /// Initiation of Cardgame.
    pub fn init(alloc: std.mem.Allocator, defaultColumnAmount: usize) !Cardgame {
        return Cardgame{ .deck = deck.PlayingCards.init(alloc), .player = try player.Attributes.init(alloc, defaultColumnAmount) };
    }

    pub fn giveCardsToPlayer(self: *Cardgame) !void {
        for (self.player.hand.cards.items.len..5) |_| {
            const picked_card = self.deck.randomLookUp();

            if (picked_card) |valid_card| {
                try self.player.addToHand(valid_card);
                _ = self.deck.removeCardByID(valid_card);
            } else {
                return;
            }
        }
    }

    /// Deinit allocator data.
    pub fn deinit(self: *Cardgame) void {
        self.deck.deinit();
        self.player.deinit();
    }

    /// Adds a standard 52+52 deck of cards for the game.
    pub fn addStandardDeck(self: *Cardgame) !void {
        for (0..2) |_| { // Repeat 2 times
            for (1..(@intFromEnum(suit.Group.Diamond)) + 1) |suitInt| {
                for (2..(@intFromEnum(rank.Hierarchy.Ace)) + 1) |rankInt| {
                    try self.deck.addCard(card.Identity{ .rank = @enumFromInt(rankInt), .suit = @enumFromInt(suitInt) });
                }
            }
        }
    }
};
