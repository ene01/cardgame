const std = @import("std");
const Deck = @import("deck.zig");
pub const Player = @import("player.zig");

pub const Cardgame = @This();

deck: Deck,
player: Player,
center_deck: Deck,

/// Initiation of the game.
pub fn init(gpa: std.mem.Allocator, default_columns: usize) !Cardgame {
    return Cardgame{ .deck = Deck.init(gpa, 108), .player = try Player.init(gpa, default_columns, 5, 10), .center_deck = Deck.init(gpa, 15) };
}

/// Deinit allocator data.
pub fn deinit(self: *Cardgame) void {
    self.deck.deinit();
    self.center_deck.deinit();
    self.player.deinit();
}
