const std = @import("std");
const deckutils = @import("deckutils.zig");
const cardutils = @import("cardutils.zig");
const log = @import("log.zig");
const Cardgame = @import("cardgame.zig");
const Player = @import("player.zig");
const Card = @import("card.zig");
const Deck = @import("deck.zig");

/// Prepares the table and players for a match.
pub fn prepareTable(g: *Cardgame) void {
    deckutils.appendStandardDeck(g.deck, 2, true);

    for (0..4) |_| {
        g.player.addToHand(deckutils.dealCard(g.deck, null));
    }

    for (0..9) |_| {
        g.player.addToDiscardDeck(deckutils.dealCard(g.deck, null));
    }
}
