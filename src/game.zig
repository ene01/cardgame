const std = @import("std");
const deck = @import("deck.zig");
const card = @import("card.zig");
pub const player = @import("player.zig").Attributes;

// TODO: Needs the game implementation itself...
pub const Cardgame = struct {
    deck: deck.CardList,
    player: player,

    /// Initiation of Cardgame.
    pub fn init(gpa: std.mem.Allocator, defaultColumnAmount: usize) !Cardgame {
        return Cardgame{ .deck = deck.CardList.init(gpa), .player = try player.init(gpa, defaultColumnAmount, 5, 10) };
    }

    pub fn giveCardsToPlayer(self: *Cardgame) !void {
        for (self.player.hand.cards.items.len..5) |_| {
            const picked_card = self.deck.randomLookUp();

            if (picked_card) |valid_card| {
                // try self.player.addToHand(valid_card);
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
            for (1..(@intFromEnum(card.Suit.Diamond)) + 1) |suitInt| {
                for (2..(@intFromEnum(card.Rank.Ace)) + 1) |rankInt| {
                    try self.deck.addCard(card.Identity{ .rank = @enumFromInt(rankInt), .suit = @enumFromInt(suitInt) });
                }
            }
        }
    }
};
