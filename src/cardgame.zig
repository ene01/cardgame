const std = @import("std");
const deck = @import("deck.zig");
const card = @import("card.zig");
pub const player = @import("player.zig").Attributes;

pub const Cardgame = struct {
    deck: deck.CardList,
    player: player,

    /// Initiation of Cardgame.
    pub fn init(gpa: std.mem.Allocator, default_columns: usize) !Cardgame {
        return Cardgame{ .deck = deck.CardList.init(gpa), .player = try player.init(gpa, default_columns, 5, 10) };
    }

    /// Deinit allocator data.
    pub fn deinit(self: *Cardgame) void {
        self.deck.deinit();
        self.player.deinit();
    }
};
