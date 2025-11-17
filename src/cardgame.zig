const std = @import("std");
const Deck = @import("deck.zig");
pub const Player = @import("player.zig");

pub const Cardgame = @This();

current_deck: Deck,
current_player: Player,
current_center_deck: Deck,

/// Initiation of the game.
pub fn init(gpa: std.mem.Allocator, default_columns: usize) !Cardgame {
    return Cardgame{ .current_deck = Deck.init(gpa, 108), .current_player = try Player.init(gpa, default_columns, 5, 10), .current_center_deck = Deck.init(gpa, 15) };
}

/// Deinit allocator data.
pub fn deinit(self: *Cardgame) void {
    self.current_deck.deinit();
    self.current_center_deck.deinit();
    self.current_player.deinit();
}
