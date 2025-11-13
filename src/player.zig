const std = @import("std");
const card = @import("card.zig");
const cardmatrix = @import("card_matrix.zig");
const deck = @import("deck.zig");

/// Player attributes: hand, rows, and status.
pub const Attributes = struct {
    hand: deck.CardList,
    /// A deck of cards intended to be discarded by the player.
    discard_deck: deck.CardList,
    tableau: cardmatrix.CardMatrix,
    is_playing: bool,

    /// Initializes and returns a player's attributes with an empty hand.
    pub fn init(gpa: std.mem.Allocator, hand_size: u16, discard_size: u16, columns: u16, column_deck_size: u16) !Attributes {
        return Attributes{ .hand = try deck.CardList.init(gpa, hand_size), .discard_deck = try deck.CardList.init(gpa, discard_size), .tableau = try cardmatrix.CardMatrix.init(gpa, columns, column_deck_size), .is_playing = true };
    }

    /// Releases memory for dynamic arrays (hand).
    pub fn deinit(self: *Attributes) void {
        self.hand.deinit();
        self.tableau.deinit();
        self.discard_deck.deinit();
    }

    /// Adds a card to the player's hand.
    pub fn addToHand(self: *Attributes, new_card: card.Identity) !void {
        try self.hand.addCard(new_card);
    }

    /// Adds a card to the player's discard deck.
    pub fn addToDiscardDeck(self: *Attributes, new_card: card.Identity) !void {
        try self.discard_deck.addCard(new_card);
    }

    /// Adds a card to the specified row.
    pub fn addToColumn(self: *Attributes, new_card: card.Identity, column_index: usize) !void {
        try self.tableau.addCard(@intCast(column_index), new_card);
    }

    /// Removes a single instance of a card from the player's hand.
    pub fn removeCardFromHand(self: *Attributes, card_to_remove: card.Identity) ?usize {
        return self.hand.removeCardByID(card_to_remove);
    }

    /// Removes a single instance of a card from the player's discard deck.
    pub fn removeCardFromDiscardDeck(self: *Attributes, card_to_remove: card.Identity) ?usize {
        return self.discard_deck.removeCardByID(card_to_remove);
    }

    /// Removes all instances of a card from the player's hand.
    pub fn removeCardsFromHand(self: *Attributes, card_to_remove: card.Identity) void {
        self.hand.removeMultipleCardsByID(card_to_remove);
    }

    /// Removes all instances of a card from the player's discard deck.
    pub fn removeCardsFromDiscardDeck(self: *Attributes, card_to_remove: card.Identity) void {
        self.discard_deck.removeMultipleCardsByID(card_to_remove);
    }

    /// Removes the last card from the specified row.
    pub fn removeCardFromColumn(self: *Attributes, column_index: usize) ?card.Identity {
        return self.tableau.removeCard(column_index);
    }
};

test "player initiation" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    try std.testing.expectEqual(4, player_one.tableau.matrix.items.len);
    try std.testing.expectEqual(0, player_one.discard_deck.len());
    try std.testing.expectEqual(0, player_one.hand.len());
    try std.testing.expect(player_one.is_playing);
}

test "add card to hand" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };

    try player_one.addToHand(card_one);

    try std.testing.expectEqual(1, player_one.hand.cards.items.len);
    try std.testing.expectEqual(card_one, player_one.hand.cards.items[0]);
}

test "add card to column" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_three = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Diamond };

    try player_one.addToColumn(card_one, 0);
    try player_one.addToColumn(card_two, 1);
    try player_one.addToColumn(card_three, 2);
    try player_one.addToColumn(card_four, 3);

    try std.testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[2].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);

    try std.testing.expectEqual(card_one, player_one.tableau.matrix.items[0].cards.items[0]);
    try std.testing.expectEqual(card_two, player_one.tableau.matrix.items[1].cards.items[0]);
    try std.testing.expectEqual(card_three, player_one.tableau.matrix.items[2].cards.items[0]);
    try std.testing.expectEqual(card_four, player_one.tableau.matrix.items[3].cards.items[0]);
}

test "add card to discard deck" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_three = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Diamond };

    try player_one.addToDiscardDeck(card_one, 0);
    try player_one.addToDiscardDeck(card_two, 1);
    try player_one.addToDiscardDeck(card_three, 2);
    try player_one.addToDiscardDeck(card_four, 3);

    try std.testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[2].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);

    try std.testing.expectEqual(card_one, player_one.tableau.matrix.items[0].cards.items[0]);
    try std.testing.expectEqual(card_two, player_one.tableau.matrix.items[1].cards.items[0]);
    try std.testing.expectEqual(card_three, player_one.tableau.matrix.items[2].cards.items[0]);
    try std.testing.expectEqual(card_four, player_one.tableau.matrix.items[3].cards.items[0]);
}

test "remove from discard deck" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };

    try player_one.discard_deck.cards.append(alloc, card_one);

    try std.testing.expectEqual(1, player_one.discard_deck.cards.items.len);
    try std.testing.expectEqual(card_one, player_one.discard_deck.cards.items[0]);

    const removed_card = player_one.removeCardFromDiscardDeck(card_one);

    try std.testing.expectEqual(0, removed_card.?);
}

test "remove from hand" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };

    try player_one.hand.cards.append(alloc, card_one);

    try std.testing.expectEqual(1, player_one.hand.cards.items.len);
    try std.testing.expectEqual(card_one, player_one.hand.cards.items[0]);

    const removed_card = player_one.removeCardFromHand(card_one);

    try std.testing.expectEqual(0, removed_card.?);
}

test "remove multiple from hand" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Diamond };

    // four equal, one different.
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_one);
    try player_one.hand.cards.append(alloc, card_two);

    try std.testing.expectEqual(5, player_one.hand.cards.items.len);

    player_one.removeCardsFromHand(card_one);

    try std.testing.expectEqual(1, player_one.hand.cards.items.len);
}

test "remove multiple from discard deck" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Diamond };

    // four equal, one different.
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_one);
    try player_one.discard_deck.cards.append(alloc, card_two);

    try std.testing.expectEqual(5, player_one.discard_deck.cards.items.len);

    player_one.removeCardsFromDiscardDeck(card_one);

    try std.testing.expectEqual(1, player_one.discard_deck.cards.items.len);
}

test "remove card from column" {
    const alloc = std.testing.allocator;

    var player_one = try Attributes.init(alloc, 5, 10, 4, 52);
    defer player_one.deinit();

    const card_one = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Spade };
    const card_two = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Heart };
    const card_three = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Club };
    const card_four = card.Identity{ .rank = card.Rank.Ace, .suit = card.Suit.Diamond };

    try player_one.tableau.matrix.items[0].cards.append(alloc, card_one);
    try player_one.tableau.matrix.items[1].cards.append(alloc, card_two);
    try player_one.tableau.matrix.items[2].cards.append(alloc, card_three);
    try player_one.tableau.matrix.items[3].cards.append(alloc, card_four);

    try std.testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[2].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);

    try std.testing.expectEqual(card_one, player_one.tableau.matrix.items[0].cards.items[0]);
    try std.testing.expectEqual(card_two, player_one.tableau.matrix.items[1].cards.items[0]);
    try std.testing.expectEqual(card_three, player_one.tableau.matrix.items[2].cards.items[0]);
    try std.testing.expectEqual(card_four, player_one.tableau.matrix.items[3].cards.items[0]);

    const removed_Card = player_one.removeCardFromColumn(2);

    try std.testing.expectEqual(card_three, removed_Card.?);

    try std.testing.expectEqual(1, player_one.tableau.matrix.items[0].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[1].cards.items.len);
    try std.testing.expectEqual(0, player_one.tableau.matrix.items[2].cards.items.len);
    try std.testing.expectEqual(1, player_one.tableau.matrix.items[3].cards.items.len);
}
