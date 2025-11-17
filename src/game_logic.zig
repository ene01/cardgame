const std = @import("std");
const Cardgame = @import("cardgame.zig");
const deck_utils = @import("deck_utils.zig");

/// Prepares the table and players for a match.
pub fn prepareTable(g: *Cardgame) void {
    deck_utils.appendStandardDeck(g.deck, 2, true);

    for (0..4) |_| {
        g.player.addToHand(deck_utils.dealCard(g.deck, null));
    }

    for (0..9) |_| {
        g.player.addToDiscardDeck(deck_utils.dealCard(g.deck, null));
    }
}
