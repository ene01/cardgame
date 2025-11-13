const std = @import("std");
const card = @import("card.zig");
const cardgame = @import("cardgame.zig");
const d_utils = @import("deck_utils.zig");

/// Prepares the table and players for a match.
pub fn prepareTable(g: *cardgame.Gameplay) void {
    d_utils.appendStandardDeck(g.deck, 2, true);

    for (0..4) |_| {
        g.player.addToHand(d_utils.dealCard(g.deck, null));
    }

    for (0..9) |_| {
        g.player.addToDiscardDeck(d_utils.dealCard(g.deck, null));
    }
}
