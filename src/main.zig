const std = @import("std");
const game = @import("game.zig");
const card = @import("card.zig");
const rank = @import("rank.zig");
const suit = @import("suit.zig");

pub fn main() !void {
    const alloc = std.heap.page_allocator;
    var cardgame = game.init(alloc);

    try cardgame.addStandardDeck();

    try cardgame.giveCardsToPlayer();

    for (0..cardgame.deck.cards.items.len) |i| {
        std.debug.print("{}\n", .{cardgame.deck.cards.items[i]});
    }

    std.debug.print("======================\n======================\n======================\n======================\n", .{});

    for (0..cardgame.player.hand.items.len) |i| {
        std.debug.print("{}\n", .{cardgame.player.hand.items[i]});
    }
}
