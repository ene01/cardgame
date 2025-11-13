const std = @import("std");
const deck = @import("deck.zig");
const card = @import("card.zig");
pub const player = @import("player.zig").Attributes;

pub const Gameplay = struct {
    deck: deck.CardList,
    player: player,
    center_deck: deck.CardList,

    /// Initiation of the game.
    pub fn init(gpa: std.mem.Allocator, default_columns: usize) !Gameplay {
        return Gameplay{ .deck = deck.CardList.init(gpa, 108), .player = try player.init(gpa, default_columns, 5, 10), .center_deck = deck.CardList.init(gpa, 15) };
    }

    /// Deinit allocator data.
    pub fn deinit(self: *Gameplay) void {
        self.deck.deinit();
        self.player.deinit();
    }
};
